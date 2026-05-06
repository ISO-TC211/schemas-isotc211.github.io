# frozen_string_literal: true

require "json"

module SchemaSite
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
