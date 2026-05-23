# frozen_string_literal: true

require "json"
require "set"
require_relative "schema_site/models"

module SchemaSite
  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      index_path = File.join(site.source, "schemas_index.json")
      return unless File.exist?(index_path)

      packages = JSON.parse(File.read(index_path)).map { |a| Package.new(a) }
      resources = load_resources(site.source)
      base_url = site.config["url"] || "https://schemas.isotc211.org"

      groups = packages.group_by { |p| [p.standard, p.part] }
      multi_part_standards = packages.group_by(&:standard).select { |_, pkgs| pkgs.map(&:part).uniq.size > 1 }.keys
      hub_count = 0

      groups.each do |(standard, part), pkgs|
        std_resources = resources[standard] || {}
        filtered = filter_resources_for_part(std_resources, standard, part, pkgs)
        site.pages << StandardPage.new(site, standard, part, pkgs, filtered, multi_part: multi_part_standards.include?(standard))
      end

      multi_part = packages.group_by(&:standard).select { |_, pkgs| pkgs.map(&:part).uniq.size > 1 }
      multi_part.each do |standard, pkgs|
        std_resources = resources[standard] || {}
        site.pages << StandardRootPage.new(site, standard, pkgs, std_resources)
      end

      hub_paths = Set.new
      packages.select(&:has_spa?).each do |pkg|
        pkg.module_versions.each do |mv|
          next if hub_paths.include?(mv.hub_path)
          hub_paths.add(mv.hub_path)
          site.pages << HubPage.new(site, pkg, mv, base_url)
          hub_count += 1
        end
      end

      puts "SchemaSite: #{groups.size} standard pages + #{hub_count} hub pages"
    end

    private

    def load_resources(source)
      path = File.join(source, "resources_index.json")
      return {} unless File.exist?(path)
      JSON.parse(File.read(path)).fetch("standards", {})
    end

    def filter_resources_for_part(std_resources, standard, part, packages)
      has_only_json = packages.all?(&:json?)

      std_resources.each_with_object({}) do |(cat, files), result|
        relevant = files.select do |f|
          path = f["path"]
          part_match = path.match(%r{\A(?:json/)?#{Regexp.escape(standard)}/(-\d+)/})
          if part_match
            part_match[1] == part
          elsif has_only_json
            cat == "examples_json"
          else
            true
          end
        end
        result[cat] = relevant unless relevant.empty?
      end
    end
  end

  class StandardPage < Jekyll::PageWithoutAFile
    include HtmlHelper

    def initialize(site, standard, part, packages, resources, multi_part: false)
      @site = site
      @base = site.source
      @dir = if part == "-" && multi_part
               "#{standard}/-"
             elsif part == "-"
               standard
             else
               "#{standard}/#{part}"
             end
      @name = "index.html"

      process(@name)
      self.data = {
        "layout" => "default",
        "title" => title_for(standard, part),
      }
      self.content = "{% raw %}\n#{build_content(standard, part, packages, resources)}\n{% endraw %}"
    end

    private

    def title_for(standard, part)
      part == "-" ? "ISO #{standard}" : "ISO #{standard} Part #{part.delete('-')}"
    end

    def build_content(standard, part, packages, resources)
      title = title_for(standard, part)
      sorted = packages.sort_by { |p| status_order(p.status) }
      cards = sorted.map { |pkg| render_card(pkg) }.join("\n")

      <<~HTML
        <section class="page-section">
          <div class="page-section__inner">
            <h1 class="page-section__title">#{esc(title)}</h1>
            <div class="schema-cards">
              #{cards}
            </div>
            #{render_resources(resources)}
          </div>
        </section>
      HTML
    end

    def render_card(pkg)
      badge_class = "badge--#{pkg.status || 'historical'}"
      badge_label = status_label(pkg.status)
      is_json = pkg.json?
      file_ext = is_json ? "JSON" : "XSD"
      files = is_json ? (pkg.file_paths || []) : (pkg.xsd_paths || [])
      browse_path = pkg.browse_path
      type_badge = is_json ? '<span class="badge badge--json">JSON</span>' : ""
      onclick = (pkg.has_spa? && browse_path) ? %[ onclick="window.location='/#{esc(url_path(browse_path))}'"] : ""

      <<~HTML
        <div class="schema-card"#{onclick}>
          <div class="schema-card__top">
            <span class="schema-card__name">#{esc(pkg.title)}</span>
            <div class="schema-card__badges">
              #{type_badge}
              <span class="badge #{badge_class}">#{badge_label}</span>
            </div>
          </div>
          <p class="schema-card__desc">#{esc(pkg.description)}</p>
          <div class="schema-card__version">Version <code>#{esc(pkg.version)}</code></div>
          <div class="schema-card__actions">
            #{(pkg.has_spa? && browse_path) ? browse_link(url_path(browse_path)) : ""}
            #{files.any? ? file_links(files.map { |f| url_path(f) }, file_ext) : ""}
          </div>
        </div>
      HTML
    end

    def browse_link(path)
      <<~HTML.chomp
        <a href="/#{esc(path)}" class="schema-card__browse" onclick="event.stopPropagation()">
          Browse schema
          <svg fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/></svg>
        </a>
      HTML
    end

    def file_links(files, ext)
      if files.size == 1
        <<~HTML.chomp
          <a href="/#{esc(files.first)}" class="schema-card__download" onclick="event.stopPropagation()" title="Download #{ext}">
            <svg fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3"/></svg>
            #{ext}
          </a>
        HTML
      else
        items = files.map do |f|
          name = File.basename(f)
          <<~HTML.chomp
            <a href="/#{esc(f)}" onclick="event.stopPropagation()">#{esc(name)}</a>
          HTML
        end.join("\n")
        <<~HTML
          <div class="schema-card__files" onclick="event.stopPropagation()">
            <span class="schema-card__files-label">#{ext} files:</span>
            #{items}
          </div>
        HTML
      end
    end

    def status_order(status)
      { "current" => 0, "draft" => 1, "historical" => 2 }[status] || 3
    end

    def status_label(status)
      { "current" => "Current", "draft" => "Draft", "historical" => "Historical" }[status] || status.to_s
    end
  end

  class StandardRootPage < Jekyll::PageWithoutAFile
    include HtmlHelper

    def initialize(site, standard, all_packages, resources)
      @site = site
      @base = site.source
      @dir = standard.to_s
      @name = "index.html"

      process(@name)
      self.data = {
        "layout" => "default",
        "title" => "ISO #{standard}",
      }
      self.content = "{% raw %}\n#{build_content(standard, all_packages, resources)}\n{% endraw %}"
    end

    private

    def build_content(standard, all_packages, resources)
      parts = all_packages.group_by(&:part).sort_by { |part, _| part == "-" ? "0" : part }

      cards = parts.map do |part, pkgs|
        label = part == "-" ? "Standalone" : "Part #{part.delete('-')}"
        url = part == "-" ? "/#{standard}/-/" : "/#{standard}/#{part}/"
        types = pkgs.map(&:type).uniq

        <<~HTML
          <a href="#{esc(url)}" class="std-card">
            <div class="std-card__number">#{esc(label)}</div>
            <div class="std-card__body">
              <span class="std-card__packages">#{pkgs.size} package#{pkgs.size != 1 ? "s" : ""}</span>
              <div class="std-card__types">
                #{types.sort.map { |t| t == "json" ? '<span class="badge badge--json">JSON</span>' : '<span class="badge badge--current">XSD</span>' }.join(" ")}
              </div>
            </div>
            <svg class="std-card__arrow" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5"/></svg>
          </a>
        HTML
      end.join("\n")

      <<~HTML
        <section class="page-section">
          <div class="page-section__inner">
            <h1 class="page-section__title">ISO #{esc(standard)}</h1>
            <p class="page-section__desc">This standard consists of multiple parts.</p>
            <div style="display:grid;gap:0.75rem;grid-template-columns:1fr;">
              #{cards}
            </div>
            #{render_resources(resources, detailed: false)}
          </div>
        </section>
      HTML
    end
  end

  class HubPage < Jekyll::PageWithoutAFile
    include HtmlHelper

    def initialize(site, pkg, mv, base_url)
      @site = site
      @base = site.source
      @dir = mv.hub_path.sub(%r{^/}, "").chomp("/")
      @name = "index.html"

      process(@name)
      self.data = {
        "layout" => "default",
        "title" => "#{mv.module_name} namespace",
      }
      self.content = "{% raw %}\n#{build_content(pkg, mv, base_url)}\n{% endraw %}"
    end

    private

    def build_content(pkg, mv, base_url)
      <<~HTML
        <section class="page-section">
          <div class="page-section__inner">
            <div class="hub-header">
              <span class="hub-header__prefix">#{esc(mv.module_name)}</span>
              <h1 class="hub-header__uri">#{esc(mv.namespace_uri)}</h1>
            </div>
            <dl class="hub-details">
              <dt>Standard</dt>
              <dd><a href="/#{esc(mv.standard)}/">ISO #{esc(mv.standard)}</a></dd>
              <dt>Part</dt>
              <dd>#{esc(mv.part_label)}</dd>
              <dt>Module</dt>
              <dd><code>#{esc(mv.module_name)}</code></dd>
              <dt>Version</dt>
              <dd><code>#{esc(mv.version)}</code></dd>
              <dt>Package</dt>
              <dd>#{esc(pkg.title)}</dd>
              <dt>Status</dt>
              <dd><span class="badge badge--#{pkg.status}">#{esc(pkg.status)}</span></dd>
            </dl>
            #{render_schema_locations(pkg, mv, base_url)}
            #{render_browse_section(pkg, mv)}
          </div>
        </section>
      HTML
    end

    def render_schema_locations(pkg, mv, base_url)
      xsd_files = pkg.xsd_paths
        .select { |p| p.include?("/#{mv.module_name}/") && p.end_with?("/#{mv.module_name}.xsd") }
        .map { |p| { name: File.basename(p), path: url_path(p) } }
      return "" if xsd_files.empty?

      items = xsd_files.map do |f|
        <<~HTML.chomp
          <li>
            <a href="/#{esc(f[:path])}">#{esc(f[:name])}</a>
            <span class="hub-xsd-url">#{esc(base_url)}/#{esc(f[:path])}</span>
          </li>
        HTML
      end.join("\n")

      <<~HTML
        <h2 class="doc-section__title">Schema locations</h2>
        <p class="doc-section__desc">The normative XML schema files for this namespace:</p>
        <ul class="hub-xsd-list">
          #{items}
        </ul>
      HTML
    end

    def render_browse_section(pkg, mv)
      return "" unless pkg.has_spa? && pkg.browse_path
      all_modules = pkg.module_versions.map(&:module_name).uniq.sort
      others = all_modules.reject { |m| m == mv.module_name }
      hint = others.empty? ? "" : " (including #{others[0]}#{others.size > 1 ? " and #{others.size - 1} more" : ""})"

      <<~HTML
        <div class="hub-browse">
          <a href="/#{esc(url_path(pkg.browse_path))}" class="schema-card__browse" style="font-size:1rem;">
            Browse interactive schema →
          </a>
          <p class="doc-section__desc" style="margin-top:0.75rem;">
            Opens the schema browser for package <code>#{esc(pkg.name)}</code>,
            covering #{all_modules.size} module#{all_modules.size == 1 ? "" : "s"}#{hint}.
          </p>
        </div>
      HTML
    end
  end
end
