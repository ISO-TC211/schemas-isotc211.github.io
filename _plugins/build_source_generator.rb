# frozen_string_literal: true

# Registers generated build artifacts as Jekyll static files so they appear in _site/.
#
# Uses Jekyll::Generator (runs during generate phase, after site reset+read)
# to register:
#   site/{standard}/{part}/{version}/browse/index.html  → SPA browser pages
#   schemas_index.json                                   → schema package index
#   resources_index.json                                 → resource catalog index

module SchemaSite
  class BuildSourceGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      source = site.source

      register_spa_pages(site, source)
    end

    private

    def register_spa_pages(site, source)
      spa_base = File.join(source, "site")
      return unless Dir.exist?(spa_base)

      files = Dir.glob(File.join(spa_base, "**/browse/index.html"))
      files.each do |path|
        relative = path.delete_prefix("#{spa_base}/")
        dir = File.dirname(relative)
        name = File.basename(relative)
        site.static_files << Jekyll::StaticFile.new(site, spa_base, dir, name)
      end
    end

  end
end
