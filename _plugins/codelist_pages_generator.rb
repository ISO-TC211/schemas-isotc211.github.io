# frozen_string_literal: true

require "rexml/document"
require_relative "schema_site/models"

module SchemaSite
  class CodelistPagesGenerator < Jekyll::Generator
    safe true
    priority :low

    CODELIST_XML = "schemas/resources/codelists/codelists.xml"

    def generate(site)
      xml_path = File.join(site.source, CODELIST_XML)
      return unless File.exist?(xml_path)

      catalogue = parse_catalogue(xml_path)
      return if catalogue.empty?

      site.pages << CodelistIndexPage.new(site, catalogue)
      catalogue.each { |cl| site.pages << CodelistDetailPage.new(site, cl) }

      puts "CodelistPages: #{catalogue.size} codelist pages"
    end

    private

    def parse_catalogue(xml_path)
      doc = REXML::Document.new(File.read(xml_path))
      root = doc.root
      return [] unless root

      collect_codelists(root)
    end

    def collect_codelists(element)
      result = []
      element.elements.each("cat:codelistItem/cat:CT_Codelist") do |cl|
        entry = build_codelist_entry(cl)
        result << entry if entry
      end
      element.elements.each("cat:subCatalogue/cat:CT_CodelistCatalogue") do |sub|
        result.concat(collect_codelists(sub))
      end
      result
    end

    def build_codelist_entry(cl)
      id = cl.attributes["id"]
      return nil unless id

      {
        "id" => id,
        "name" => scoped_text(cl, "name") || id,
        "identifier" => scoped_text(cl, "identifier") || id,
        "definition" => char_text(cl, "definition"),
        "description" => char_text(cl, "description"),
        "values" => extract_values(cl),
      }
    end

    def extract_values(cl)
      result = []
      cl.elements.each("cat:codeEntry/cat:CT_CodelistValue") do |entry|
        entry_id = entry.attributes["id"]
        next unless entry_id
        result << {
          "id" => entry_id,
          "identifier" => scoped_text(entry, "identifier") || entry_id,
          "name" => scoped_text(entry, "name"),
          "definition" => char_text(entry, "definition"),
          "description" => char_text(entry, "description"),
        }
      end
      result
    end

    def scoped_text(element, child)
      element.elements["cat:#{child}/gco:ScopedName"]&.text
    end

    def char_text(element, child)
      element.elements["cat:#{child}/gco:CharacterString"]&.text
    end
  end

  class CodelistIndexPage < Jekyll::PageWithoutAFile
    include HtmlHelper

    def initialize(site, codelists)
      @site = site
      @base = site.source
      @dir = "resources/codelists"
      @name = "index.html"

      process(@name)
      self.data = {
        "layout" => "default",
        "title" => "ISO/TC 211 Codelist Catalogues",
      }
      self.content = "{% raw %}\n#{build_content(codelists)}\n{% endraw %}"
    end

    private

    def build_content(codelists)
      rows = codelists.map do |cl|
        desc = cl["description"] || cl["definition"] || ""
        slug = cl["id"].tr("_", "-")
        <<~HTML.chomp
          <tr class="cl-row">
            <td class="cl-row__name"><a href="/resources/codelists/#{esc(slug)}/">#{esc(cl['name'])}</a></td>
            <td class="cl-row__id"><code>#{esc(cl['id'])}</code></td>
            <td class="cl-row__desc">#{esc(truncate(desc, 80))}</td>
            <td class="cl-row__count">#{cl['values']&.size || 0}</td>
          </tr>
        HTML
      end.join("\n")

      <<~HTML
        <section class="page-section">
          <div class="page-section__inner">
            <h1 class="page-section__title">ISO/TC 211 Codelist Catalogues</h1>
            <p class="page-section__desc">
              Canonical codelist definitions for all ISO/TC 211 standards.
              Source: <a href="/resources/codelists/codelists.xml">codelists.xml</a>
            </p>
            <div class="cl-uri-box">
              <span class="cl-uri-box__label">Canonical URL pattern</span>
              <code class="cl-uri-box__value">https://schemas.isotc211.org/resources/codelists/codelists.xml#<em>{CodelistId}</em></code>
            </div>
            <div class="cl-table-wrap">
              <table class="cl-table">
                <thead>
                  <tr>
                    <th>Codelist</th>
                    <th>Identifier</th>
                    <th>Description</th>
                    <th>Values</th>
                  </tr>
                </thead>
                <tbody>
                  #{rows}
                </tbody>
              </table>
            </div>
          </div>
        </section>
      HTML
    end

    def truncate(str, max)
      str.length > max ? "#{str[0..(max - 3)]}..." : str
    end
  end

  class CodelistDetailPage < Jekyll::PageWithoutAFile
    include HtmlHelper

    def initialize(site, codelist)
      slug = codelist["id"].tr("_", "-")
      @site = site
      @base = site.source
      @dir = "resources/codelists/#{slug}"
      @name = "index.html"

      process(@name)
      self.data = {
        "layout" => "default",
        "title" => codelist["name"],
      }
      self.content = "{% raw %}\n#{build_content(codelist)}\n{% endraw %}"
    end

    private

    def build_content(cl)
      rows = (cl["values"] || []).map do |v|
        desc = v["description"] || v["definition"] || ""
        <<~HTML.chomp
          <tr class="cl-row">
            <td class="cl-row__name"><code>#{esc(v['identifier'])}</code></td>
            <td class="cl-row__desc">#{esc(truncate(desc, 120))}</td>
            <td class="cl-row__id"><code>#{esc(v['id'])}</code></td>
          </tr>
        HTML
      end.join("\n")

      definition_html = cl["definition"] ? "<dt>Definition</dt><dd>#{esc(cl['definition'])}</dd>" : ""
      description_html = cl["description"] && cl["description"] != cl["definition"] ? "<dt>Description</dt><dd>#{esc(cl['description'])}</dd>" : ""

      <<~HTML
        <section class="page-section">
          <div class="page-section__inner">
            <div class="cl-breadcrumb">
              <a href="/resources/codelists/">Codelist Catalogues</a>
              <span class="cl-breadcrumb__sep">&rsaquo;</span>
              <span>#{esc(cl['name'])}</span>
            </div>
            <h1 class="page-section__title">#{esc(cl['name'])}</h1>
            <dl class="cl-detail">
              <dt>Identifier</dt>
              <dd><code class="cl-detail__id">#{esc(cl['id'])}</code></dd>
              #{definition_html}
              #{description_html}
              <dt>Canonical URI</dt>
              <dd class="cl-detail__uri">
                <code>https://schemas.isotc211.org/resources/codelists/codelists.xml##{esc(cl['id'])}</code>
              </dd>
              <dt>Defined values</dt>
              <dd>#{cl['values']&.size || 0} codes</dd>
            </dl>
            <div class="cl-table-wrap">
              <table class="cl-table">
                <thead>
                  <tr>
                    <th>Value</th>
                    <th>Description</th>
                    <th>Fragment ID</th>
                  </tr>
                </thead>
                <tbody>
                  #{rows}
                </tbody>
              </table>
            </div>
          </div>
        </section>
      HTML
    end

    def truncate(str, max)
      str.length > max ? "#{str[0..(max - 3)]}..." : str
    end
  end
end
