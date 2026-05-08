# frozen_string_literal: true

require "find"
require_relative "schema_site/models"

# Registers build artifacts as Jekyll static files:
#   site/{standard}/{part}/{module}/{version}/browse/index.html  → SPA browser pages
#   schemas/{standard}/.../*.{xsd,json,xml,...}                  → schema data files
module SchemaSite
  class BuildSourceGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      source = site.source
      register_spa_pages(site, source)
      register_schema_data(site, source)
    end

    private

    def register_spa_pages(site, source)
      spa_base = File.join(source, "site")
      return unless Dir.exist?(spa_base)

      Find.find(spa_base) do |path|
        next if File.directory?(path)
        relative = path.delete_prefix("#{spa_base}/")
        dir = File.dirname(relative)
        name = File.basename(relative)
        site.static_files << Jekyll::StaticFile.new(site, spa_base, dir, name)
      end
    end

    def register_schema_data(site, source)
      schemas_base = File.join(source, "schemas")
      return unless Dir.exist?(schemas_base)

      Find.find(schemas_base) do |path|
        if File.directory?(path)
          Find.prune if SKIP_DIRS.include?(File.basename(path))
          next
        end

        next unless DATA_EXTENSIONS.include?(File.extname(path).downcase)

        relative = path.delete_prefix("#{schemas_base}/")
        dir = File.dirname(relative)
        name = File.basename(relative)
        site.static_files << Jekyll::StaticFile.new(site, schemas_base, dir, name)
      end
    end
  end
end
