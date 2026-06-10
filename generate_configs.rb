#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"

module SchemaIndex
  SCHEMA_LOCATION_MAPPINGS = [
    { "from" => '^http://schemas\.opengis\.net/gml/3\.2\.1/(.+\.xsd)$',
      "to" => "../schemas/19136/-/gml/1.0/\\1", "pattern" => true },
    { "from" => "http://schemas.opengis.net/gml/3.1.1/base/gml.xsd",
      "to" => "../schemas/19136/-/gml/1.0/gml.xsd", "pattern" => false },
    { "from" => '^http://schemas\.opengis\.net/gml/3\.1\.1/(?:base/)?(.+\.xsd)$',
      "to" => "../schemas/19136/-/gml/1.0/\\1", "pattern" => true },
    { "from" => "http://www.w3.org/1999/xlink.xsd",
      "to" => "../vendor_schemas/xlink/xlinks.xsd", "pattern" => false },
    { "from" => "https://www.w3.org/1999/xlink.xsd",
      "to" => "../vendor_schemas/xlink/xlinks.xsd", "pattern" => false },
    { "from" => "http://www.w3.org/2001/xml.xsd",
      "to" => "../vendor_schemas/w3c/xml.xsd", "pattern" => false },

    # Double schemas/ prefix: schemas.isotc211.org/schemas/X
    { "from" => '^https://schemas\.isotc211\.org/schemas/(.+\.xsd)$',
      "to" => "../schemas/\\1", "pattern" => true },

    # Moved directories: HTTPS URLs for old paths → new local paths
    { "from" => '^https://schemas\.isotc211\.org/19110/fcc/(.+\.xsd)$',
      "to" => "../schemas/19110/-/fcc/\\1", "pattern" => true },
    { "from" => '^https://schemas\.isotc211\.org/19110/gfc/(.+\.xsd)$',
      "to" => "../schemas/19110/-/gfc/\\1", "pattern" => true },
    { "from" => '^https://schemas\.isotc211\.org/19111/rbc/(.+\.xsd)$',
      "to" => "../schemas/19111/-/rbc/\\1", "pattern" => true },
    { "from" => '^https://schemas\.isotc211\.org/19111/rce/(.+\.xsd)$',
      "to" => "../schemas/19111/-/rce/\\1", "pattern" => true },
    { "from" => '^https://schemas\.isotc211\.org/19155/gpi/(.+\.xsd)$',
      "to" => "../schemas/19155/-/gpi/\\1", "pattern" => true },
    { "from" => '^https://schemas\.isotc211\.org/19165/gpm/(.+\.xsd)$',
      "to" => "../schemas/19165/-/gpm/\\1", "pattern" => true },
    { "from" => '^https://schemas\.isotc211\.org/19119/srv/(.+\.xsd)$',
      "to" => "../schemas/19119/-/srv/\\1", "pattern" => true },

    # Catch-all: isotc211.org HTTPS → local schemas dir
    { "from" => '^https://schemas\.isotc211\.org/(.+\.xsd)$',
      "to" => "../schemas/\\1", "pattern" => true },
    { "from" => '^http://schemas\.opengis\.net/sensorML/2\.0/(.+\.xsd)$',
      "to" => "../vendor_schemas/ogc/sensorML/2.0/\\1", "pattern" => true },
    { "from" => '^http://schemas\.opengis\.net/sweCommon/2\.0/(.+\.xsd)$',
      "to" => "../vendor_schemas/ogc/sweCommon/2.0/\\1", "pattern" => true },
  ].freeze

  NAMESPACE_MAPPINGS = [
    { "prefix" => "xs", "uri" => "http://www.w3.org/2001/XMLSchema" },
    { "prefix" => "gml", "uri" => "http://www.opengis.net/gml/3.2" },
    { "prefix" => "xlink", "uri" => "http://www.w3.org/1999/xlink" },
  ].freeze

  ISO_LOGO_URL = "https://www.isotc211.org/assets/iso-red.svg"

  APPEARANCE = {
    "logos" => {
      "square" => {
        "light" => { "url" => ISO_LOGO_URL },
        "dark" => { "url" => ISO_LOGO_URL },
      },
      "long" => {
        "light" => { "url" => ISO_LOGO_URL },
        "dark" => { "url" => ISO_LOGO_URL },
      },
      "icon" => {
        "light" => { "url" => ISO_LOGO_URL },
        "dark" => { "url" => ISO_LOGO_URL },
      },
      "lutaml_logo" => {
        "light" => { "url" => ISO_LOGO_URL },
        "dark" => { "url" => ISO_LOGO_URL },
      },
    },
    "colors" => {
      "primary" => "#0061ad",
      "primary_light" => "#3385d6",
      "primary_dark" => "#003f73",
      "accent" => "#e3000f",
      "background_primary" => "#ffffff",
      "background_secondary" => "#f8fafc",
    },
    "typography" => {
      "font_family" => "'Inter', system-ui, -apple-system, BlinkMacSystemFont, sans-serif",
      "mono_font_family" => "'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace",
    },
    "subtitle" => "ISO/TC 211 Schemas",
  }.freeze

  RESOURCE_CATEGORIES = {
    "transforms"   => { glob: "*/resources/transforms/**/*.xsl",   label: "XSLT Transforms" },
    "schematron"   => { glob: "**/*.sch",                          label: "Schematron Rules" },
    "examples_xml" => { glob: "**/examples/*.xml",                 label: "XML Examples" },
    "examples_json"=> { glob: "**/examples/*.json",                label: "JSON Examples" },
    "codelists"    => { glob: "*/resources/codelists/**/*.xml",    label: "Codelist Dictionaries" },
    "bundles"      => { glob: "*/resources/bundles/**/*.zip",      label: "Download Packages" },

    "general_codelists" => { glob: "resources/codelists/**/*.xml", label: "General Codelist Catalogues" },
  }.freeze

  # ── Package base class ──

  class Package
    attr_reader :name, :title, :description, :standard, :status, :files, :version, :part

    def initialize(attrs)
      @name = attrs["name"]
      @title = attrs["title"] || @name
      @description = attrs["description"] || "Interactive documentation for #{@title}."
      @standard = attrs["standard"]
      @status = attrs["status"] || "current"
      @files = attrs["files"] || []
      @version = extract_version
      @part = attrs.fetch("part") { infer_part }
    end

    def type
      raise NotImplementedError
    end

    def has_spa?
      raise NotImplementedError
    end

    def to_index_entry
      {
        "name" => @title,
        "slug" => @name,
        "version" => @version,
        "status" => @status,
        "standard" => @standard,
        "part" => @part,
        "description" => @description,
        "type" => type,
        "has_spa" => has_spa?,
        "file_paths" => @files.map { |f| "schemas/#{f}" },
      }
    end

    def validate!(schemas_dir)
      @files.each do |f|
        path = File.join(schemas_dir, f)
        unless File.exist?(path)
          $stderr.puts "  ERROR: #{@name}: #{f} not found at #{path}"
          raise "Missing file: #{f}"
        end
      end
    end

    private

    def extract_version
      match = @name.match(/[\d.]+$/)
      match ? match[0] : "1.0"
    end

    def infer_part
      @files.first&.then { |f| f[%r{^[^/]+/([^/]+)}, 1] } || "-"
    end
  end

  # ── XSD Package ──

  class XsdPackage < Package
    def type = "xsd"
    def has_spa? = true

    def primary_module
      @files.first&.then { |f| f[%r{^[^/]+/[^/]+/([^/]+)}, 1] } || name
    end

    def browse_path
      "#{standard}/#{part}/#{primary_module}/#{version}/browse/"
    end

    def spa_output_file
      "site/#{standard}/#{part}/#{primary_module}/#{version}/browse/index.html"
    end

    def to_index_entry
      super.merge("browse_path" => browse_path, "xsd_paths" => @files.map { |f| "schemas/#{f}" })
    end

    def generate_config(schemas_dir, config_dir)
      all_files = discover_all_xsd_files(schemas_dir)
      config = {
        "metadata" => build_metadata,
        "build" => {
          "xsd_mode" => "include_all",
          "resolution_mode" => "resolved",
          "serialization_format" => "marshal",
        },
        "files" => all_files,
        "schema_location_mappings" => SCHEMA_LOCATION_MAPPINGS,
        "namespace_mappings" => NAMESPACE_MAPPINGS,
        "appearance" => APPEARANCE,
      }

      path = File.join(config_dir, "#{@name}.yml")
      File.write(path, YAML.dump(config))
      puts "Generated: #{path}"
    end

    private

    def build_metadata
      {
        "name" => @name,
        "version" => "1.0.0",
        "title" => @title,
        "description" => @description,
        "license" => "ISO",
        "authors" => [{ "name" => "ISO/TC 211" }],
        "links" => [
          { "name" => "Homepage", "url" => "https://schemas.isotc211.org" },
          { "name" => "Repository", "url" => "https://github.com/ISO-TC211/schemas-isotc211.github.io" },
          { "name" => "ISO/TC 211", "url" => "https://www.isotc211.org" },
        ],
      }
    end

    def discover_all_xsd_files(schemas_dir)
      dirs = @files.map { |f| File.join(schemas_dir, File.dirname(f)) }.uniq
      all = dirs.flat_map { |dir| Dir.glob(File.join(dir, "*.xsd")).sort }
      all.uniq.sort.map { |f| "../#{f.delete_prefix("#{File.dirname(schemas_dir)}/")}" }
    end
  end

  # ── JSON Package ──

  class JsonPackage < Package
    def type = "json"
    def has_spa? = true

    def primary_module
      @files.each do |f|
        m = f.match(%r{^json/\d{5}/[^/]+/([^/]+)/\d})
        return m[1] if m
      end
      "schema"
    end

    def browse_path
      "#{standard}/#{part}/#{primary_module}/#{version}/json/browse/"
    end

    def spa_output_file
      "site/#{browse_path}index.html"
    end

    def to_index_entry
      super.merge("browse_path" => browse_path)
    end
  end

  # ── Resource Scanner ── auto-discovers resources from filesystem

  class ResourceScanner
    def initialize(schemas_dir, descriptions_file = nil)
      @schemas_dir = schemas_dir
      @descriptions = load_descriptions(descriptions_file)
    end

    def scan
      RESOURCE_CATEGORIES.each_with_object({}) do |(category, config), result|
        files = Dir.glob(config[:glob], base: @schemas_dir).sort
        result[category] = files.map { |f| build_entry(f, category) }
      end
    end

    CROSS_CUTTING_CATEGORIES = %w[general_codelists].freeze

    def scan_by_standard(packages)
      standards = packages.map { |p| p.standard }.uniq.sort
      resources = scan

      result = standards.each_with_object({}) do |std, acc|
        std_resources = {}
        resources.each do |category, files|
          next if CROSS_CUTTING_CATEGORIES.include?(category)
          matching = files.select { |f| f["path"].start_with?("#{std}/") || f["path"].start_with?("json/#{std}/") }
          std_resources[category] = matching unless matching.empty?
        end
        acc[std] = std_resources unless std_resources.empty?
      end

      cross_cutting = {}
      resources.each do |category, files|
        next unless CROSS_CUTTING_CATEGORIES.include?(category)
        cross_cutting[category] = files unless files.empty?
      end
      result["_shared"] = cross_cutting unless cross_cutting.empty?

      result
    end

    def compute_resource_counts(packages)
      resources = scan_by_standard(packages)
      packages.each_with_object({}) do |pkg, counts|
        std_resources = resources[pkg.standard] || {}
        total = {}
        std_resources.each do |cat, files|
          relevant = files.select { |f| resource_relevant?(f["path"], cat, pkg) }
          total[cat] = relevant.size unless relevant.empty?
        end
        counts[pkg.name] = total unless total.empty?
      end
    end

    def resource_relevant?(path, category, pkg)
      return false if CROSS_CUTTING_CATEGORIES.include?(category)
      part_match = path.match(%r{\A(?:json/)?#{Regexp.escape(pkg.standard)}/(-\d+)/})
      if part_match
        return false unless part_match[1] == pkg.part
      end
      # JSON examples belong only to JSON packages
      if category == "examples_json"
        return pkg.type == "json"
      end
      # All other resource categories are XML-only
      return pkg.type == "xsd"
    end

    private

    def build_entry(path, _category)
      {
        "path" => path,
        "name" => File.basename(path),
        "description" => @descriptions[path] || humanize_filename(File.basename(path)),
      }
    end

    def humanize_filename(name)
      ext = File.extname(name)
      base = File.basename(name, ext)
      base.gsub(/[-_]/, " ").sub(/(\d+\.\d+(?:\.\d+)?)/, '(\1)').strip
    end

    def load_descriptions(file)
      return {} unless file && File.exist?(file)
      YAML.load_file(file) || {}
    rescue StandardError
      {}
    end
  end

  # ── Generator ──

  class Generator
    def initialize(base_dir)
      @base_dir = base_dir
      @schemas_dir = File.join(base_dir, "schemas")
      @config_dir = File.join(base_dir, "configs")
      @descriptions_file = File.join(base_dir, "resource_descriptions.yml")
    end

    def run
      packages = load_packages
      validate_all(packages)
      generate_configs(packages)
      write_index(packages)
      write_resources_index(packages)
      write_spa_makefile(packages)
      puts "\n#{packages.size} packages configured."
    end

    private

    def load_packages
      packages = load_manifest("lxr_packages.yml", XsdPackage)
      packages += load_manifest("ljr_packages.yml", JsonPackage)
      packages
    end

    def load_manifest(filename, klass)
      path = File.join(@schemas_dir, filename)
      unless File.exist?(path)
        raise "Manifest #{filename} not found in schemas/ — it must be defined in the schemas directory"
      end

      manifest = YAML.load_file(path)
      (manifest["packages"] || []).map { |attrs| klass.new(attrs) }
    end

    def validate_all(packages)
      errors = []
      packages.each do |pkg|
        begin
          pkg.validate!(@schemas_dir)
        rescue StandardError
          errors << pkg.name
        end
      end
      unless errors.empty?
        $stderr.puts "ERROR: #{errors.size} package(s) have missing files"
        exit 1
      end
    end

    def generate_configs(packages)
      Dir.mkdir(@config_dir) unless Dir.exist?(@config_dir)

      packages.each do |pkg|
        if pkg.is_a?(XsdPackage)
          pkg.generate_config(@schemas_dir, @config_dir)
        else
          puts "Indexed (#{pkg.type}): #{pkg.name}"
        end
      end
    end

    def write_index(packages)
      scanner = ResourceScanner.new(@schemas_dir, @descriptions_file)
      resource_counts = scanner.compute_resource_counts(packages)

      index = packages.map do |pkg|
        entry = pkg.to_index_entry
        counts = resource_counts[pkg.name]
        entry["resource_counts"] = counts if counts && !counts.empty?
        entry
      end

      path = File.join(@base_dir, "schemas_index.json")
      File.write(path, JSON.pretty_generate(index))
      puts "Generated: #{path}"
    end

    def write_resources_index(packages)
      scanner = ResourceScanner.new(@schemas_dir, @descriptions_file)
      resources = scanner.scan_by_standard(packages)

      path = File.join(@base_dir, "resources_index.json")
      File.write(path, JSON.pretty_generate("standards" => resources))
      puts "Generated: #{path}"
    end

    def write_spa_makefile(packages)
      xsd_packages = packages.select { |p| p.is_a?(XsdPackage) }
      json_packages = packages.select { |p| p.is_a?(JsonPackage) }

      xsd_rules = xsd_packages.map do |pkg|
        "site/#{pkg.browse_path}index.html: build/#{pkg.name}.lxr\n\t@mkdir -p $(dir $@)\n\t$(LUTAML_BUNDLE) bundle exec lutaml-xsd spa $< --mode inlined --output $@\n"
      end.join("\n")

      json_rules = json_packages.map do |pkg|
        schema_files = pkg.files.map { |f| File.join(@schemas_dir, f) }.join(" \\\n    ")
        "site/#{pkg.browse_path}index.html:\n\t@mkdir -p $(dir $@)\n\t$(LUTAML_BUNDLE) bundle exec lutaml-jsonschema spa \\\n    #{schema_files} \\\n    -o $(dir $@) --title \"#{pkg.title}\" \\\n    --logo \"#{ISO_LOGO_URL}\" --subtitle \"ISO/TC 211 Schemas\"\n"
      end.join("\n")

      all_spas = (xsd_packages + json_packages).map { |pkg| "site/#{pkg.browse_path}index.html" }.join(" \\\n  ")

      path = File.join(@config_dir, "Makefile.spa")
      File.write(path, <<~MAKEFILE)
        # Auto-generated by generate_configs.rb — do not edit
        LUTAML_BUNDLE := BUNDLE_GEMFILE=schemas/Gemfile BUNDLE_PATH=vendor/bundle-lutaml

        SPA_FILES := \\
          #{all_spas}

        #{xsd_rules}

        #{json_rules}
      MAKEFILE
      puts "Generated: #{path}"
    end
  end
end

SchemaIndex::Generator.new(__dir__).run
