# frozen_string_literal: true

require "json"

module SchemaSite
  DATA_EXTENSIONS = %w[.xsd .xml .xsl .xslt .sch .json .zip .gml .svg .png .txt .adoc .ent .dtd].freeze
  SKIP_DIRS = %w[.git vendor _site node_modules tools].freeze

  RESOURCE_CATEGORIES = {
    "transforms"    => { label: "XSLT Transforms",       color: "orange", icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M4.098 19.902a3.75 3.75 0 005.304 0l6.401-6.402M6.75 21A3.75 3.75 0 013 17.25V4.125C3 3.504 3.504 3 4.125 3h5.25C9.996 3 10.5 3.504 10.5 4.125v4.072M6.75 21a3.75 3.75 0 003.75-3.75V8.197M6.75 21h13.125c.621 0 1.125-.504 1.125-1.125v-5.25c0-.621-.504-1.125-1.125-1.125h-4.072M10.5 8.197l2.88-2.88c.438-.439 1.15-.439 1.59 0l3.712 3.713c.44.44.44 1.152 0 1.59l-2.879 2.88M6.75 17.25h.008v.008H6.75v-.008z"/>' },
    "schematron"    => { label: "Schematron Rules",      color: "purple", icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 01-1.043 3.296 3.745 3.745 0 01-3.296 1.043A3.745 3.745 0 0112 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 01-3.296-1.043 3.745 3.745 0 01-1.043-3.296A3.745 3.745 0 013 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 011.043-3.296 3.746 3.746 0 013.296-1.043A3.746 3.746 0 0112 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 013.296 1.043 3.746 3.746 0 011.043 3.296A3.745 3.745 0 0121 12z"/>' },
    "examples_xml"  => { label: "XML Examples",          color: "blue",   icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"/>' },
    "examples_json" => { label: "JSON Examples",         color: "blue",   icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"/>' },
    "codelists"     => { label: "Codelist Dictionaries", color: "teal",   icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"/>' },
    "bundles"       => { label: "Download Packages",     color: "green",  icon_svg: '<path stroke-linecap="round" stroke-linejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"/>' },
  }.freeze

  module HtmlHelper
    def esc(str)
      str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
    end

    def url_path(path)
      path.to_s.sub(%r{\Aschemas/}, "")
    end

    def render_resources(resources, detailed: true)
      return "" if resources.nil? || resources.empty?

      sections = []
      RESOURCE_CATEGORIES.each do |category, config|
        files = resources[category]
        next if files.nil? || files.empty?

        items = files.map do |f|
          desc = (detailed && f["description"] && f["description"] != f["name"]) ? %{<span class="res-item__desc">#{esc(f["description"])}</span>} : ""
          <<~HTML.chomp
            <a href="/#{esc(url_path(f['path']))}" class="res-item">
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
  end

  class ModuleVersion
    attr_reader :standard, :part, :module_name, :version

    def initialize(standard:, part:, module_name:, version:)
      @standard = standard
      @part = part
      @module_name = module_name
      @version = version
    end

    def hub_path
      "/#{standard}/#{part}/#{module_name}/#{version}/"
    end

    def browse_path
      "/#{standard}/#{part}/#{module_name}/#{version}/browse/"
    end

    def part_label
      part == "-" ? "Standalone" : "Part #{part.delete('-')}"
    end

    def ns_version
      segments = version.split(".")
      "#{segments[0]}.#{segments[1]}"
    end

    def namespace_uri
      "https://schemas.isotc211.org/#{standard}/#{part}/#{module_name}/#{ns_version}"
    end

    def self.extract_from_path(path, standard: nil)
      stripped = path.sub(%r{^schemas/}, "")
      return nil unless stripped =~ %r{^(\d{5})/([^/]+)/([^/]+)/([^/]+)/.+\.xsd$}
      new(
        standard: standard || $1,
        part: $2,
        module_name: $3,
        version: $4,
      )
    end
  end

  class Package
    attr_reader :name, :title, :description, :status, :standard, :part, :version,
                :type, :xsd_paths, :file_paths, :has_spa, :browse_path, :slug

    def initialize(attrs)
      @name = attrs["name"]
      @title = attrs["title"] || @name
      @description = attrs["description"] || ""
      @status = attrs["status"] || "current"
      @standard = attrs["standard"]
      @part = attrs.fetch("part") { compute_part }
      @version = attrs["version"]
      @type = attrs["type"] || "xsd"
      @xsd_paths = attrs["xsd_paths"] || []
      @file_paths = attrs["file_paths"] || []
      @has_spa = attrs["has_spa"]
      @browse_path = attrs["browse_path"]
      @slug = attrs["slug"] || @name
    end

    def has_spa?
      !!has_spa
    end

    def json?
      type == "json"
    end

    def module_versions
      return @module_versions if defined?(@module_versions)

      paths = (xsd_paths + file_paths).uniq
      @module_versions = paths.filter_map do |path|
        ModuleVersion.extract_from_path(path, standard: standard)
      end.uniq { |mv| mv.hub_path }
    end

    private

    def compute_part
      mv = module_versions.first
      mv&.part || "-"
    end
  end
end
