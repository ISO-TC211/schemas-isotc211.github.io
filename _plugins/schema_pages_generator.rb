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
            %w[examples_json codelists bundles].include?(cat)
          else
            true
          end
        end
        result[cat] = relevant unless relevant.empty?
      end
    end
  end

  RESOURCE_CATEGORIES = {
    "transforms"    => { label: "XSLT Transforms",       color: "orange", icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M4.098 19.902a3.75 3.75 0 005.304 0l6.401-6.402M6.75 21A3.75 3.75 0 013 17.25V4.125C3 3.504 3.504 3 4.125 3h5.25C9.996 3 10.5 3.504 10.5 4.125v4.072M6.75 21a3.75 3.75 0 003.75-3.75V8.197M6.75 21h13.125c.621 0 1.125-.504 1.125-1.125v-5.25c0-.621-.504-1.125-1.125-1.125h-4.072M10.5 8.197l2.88-2.88c.438-.439 1.15-.439 1.59 0l3.712 3.713c.44.44.44 1.152 0 1.59l-2.879 2.88M6.75 17.25h.008v.008H6.75v-.008z"/>' },
    "schematron"    => { label: "Schematron Rules",      color: "purple", icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 01-1.043 3.296 3.745 3.745 0 01-3.296 1.043A3.745 3.745 0 0112 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 01-3.296-1.043 3.745 3.745 0 01-1.043-3.296A3.745 3.745 0 013 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 011.043-3.296 3.746 3.746 0 013.296-1.043A3.746 3.746 0 0112 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 013.296 1.043 3.746 3.746 0 011.043 3.296A3.745 3.745 0 0121 12z"/>' },
    "examples_xml"  => { label: "XML Examples",          color: "blue",   icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"/>' },
    "examples_json" => { label: "JSON Examples",         color: "blue",   icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"/>' },
    "codelists"     => { label: "Codelist Dictionaries", color: "teal",   icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"/>' },
    "bundles"       => { label: "Download Packages",     color: "green",  icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"/>' },
  }.freeze

  class StandardPage < Jekyll::PageWithoutAFile
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
      resources_section = render_resources(standard, part, resources)

      <<~HTML
        <section class="page-section">
          <div class="page-section__inner">
            <h1 class="page-section__title">#{esc(title)}</h1>
            <div class="schema-cards">
              #{cards}
            </div>
            #{resources_section}
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
      onclick = (pkg.has_spa? && browse_path) ? %[ onclick="window.location='/#{esc(browse_path)}'"] : ""

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
            #{(pkg.has_spa? && browse_path) ? browse_link(browse_path) : ""}
            #{files.any? ? file_links(files, file_ext) : ""}
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

    def render_resources(standard, part, resources)
      return "" if resources.nil? || resources.empty?

      sections = []
      RESOURCE_CATEGORIES.each do |category, config|
        files = resources[category]
        next if files.nil? || files.empty?

        items = files.map do |f|
          desc = (f['description'] && f['description'] != f['name']) ? %{<span class="res-item__desc">#{esc(f['description'])}</span>} : ""
          <<~HTML.chomp
            <a href="/schemas/#{esc(f['path'])}" class="res-item">
              <span class="res-item__dot res-item__dot--#{config[:color]}"></span>
              <span class="res-item__name">#{esc(f['name'])}</span>
              #{desc}
            </a>
          HTML
        end.join("\n")

        sections << <<~HTML
          <div class="res-category">
            <div class="res-category__header">
              <span class="res-category__icon res-category__icon--#{config[:color]}">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">#{config[:icon_svg]}</svg>
              </span>
              <span class="res-category__title">#{config[:label]}</span>
              <span class="res-group__count">#{files.size} file#{files.size != 1 ? 's' : ''}</span>
            </div>
            <div class="res-list">
              #{items}
            </div>
          </div>
        HTML
      end

      return "" if sections.empty?

      <<~HTML
        <div class="resources-section">
          <h2 class="resources-section__title">Resources</h2>
          #{sections.join("\n")}
        </div>
      HTML
    end

    def status_order(status)
      { "current" => 0, "draft" => 1, "historical" => 2 }[status] || 3
    end

    def status_label(status)
      { "current" => "Current", "draft" => "Draft", "historical" => "Historical" }[status] || status.to_s
    end

    def esc(str)
      str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
    end
  end

  class StandardRootPage < Jekyll::PageWithoutAFile
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

      resources_section = render_resources(standard, resources)

      <<~HTML
        <section class="page-section">
          <div class="page-section__inner">
            <h1 class="page-section__title">ISO #{esc(standard)}</h1>
            <p class="page-section__desc">This standard consists of multiple parts.</p>
            <div style="display:grid;gap:0.75rem;grid-template-columns:1fr;">
              #{cards}
            </div>
            #{resources_section}
          </div>
        </section>
      HTML
    end

    def render_resources(standard, resources)
      return "" if resources.nil? || resources.empty?

      sections = []
      RESOURCE_CATEGORIES.each do |category, config|
        files = resources[category]
        next if files.nil? || files.empty?

        items = files.map do |f|
          <<~HTML.chomp
            <a href="/schemas/#{esc(f['path'])}" class="res-item">
              <span class="res-item__dot res-item__dot--#{config[:color]}"></span>
              <span class="res-item__name">#{esc(f['name'])}</span>
            </a>
          HTML
        end.join("\n")

        sections << <<~HTML
          <div class="res-category">
            <div class="res-category__header">
              <span class="res-category__icon res-category__icon--#{config[:color]}">
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">#{config[:icon_svg]}</svg>
              </span>
              <span class="res-category__title">#{config[:label]}</span>
              <span class="res-group__count">#{files.size} file#{files.size != 1 ? 's' : ''}</span>
            </div>
            <div class="res-list">
              #{items}
            </div>
          </div>
        HTML
      end

      return "" if sections.empty?

      <<~HTML
        <div class="resources-section">
          <h2 class="resources-section__title">Resources</h2>
          #{sections.join("\n")}
        </div>
      HTML
    end

    def esc(str)
      str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
    end
  end

  class HubPage < Jekyll::PageWithoutAFile
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
        .map { |p| { name: File.basename(p), path: p } }
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
          <a href="/#{esc(pkg.browse_path)}" class="schema-card__browse" style="font-size:1rem;">
            Browse interactive schema →
          </a>
          <p class="doc-section__desc" style="margin-top:0.75rem;">
            Opens the schema browser for package <code>#{esc(pkg.name)}</code>,
            covering #{all_modules.size} module#{all_modules.size == 1 ? "" : "s"}#{hint}.
          </p>
        </div>
      HTML
    end

    def esc(str)
      str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
    end
  end
end
