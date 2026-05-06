# Copies generated build artifacts (SPA HTMLs, index JSONs) into Jekyll's
# static_files collection so they appear in _site/ without requiring
# `source:` to point at a staging directory.
#
# This replaces the old `source: build_source` _config.yml approach,
# which broke Jekyll by redirecting it away from the project root.
#
# Files handled:
#   site/*.html        → _site/site/*.html        (SPA browser pages)
#   schemas_index.json → _site/schemas_index.json  (schema package index)
#   resources_index.json → _site/resources_index.json (resource catalog)

Jekyll::Hooks.register :site, :after_init do |site|
  source = site.source

  # Register SPA HTML files from site/ as static files
  spa_dir = File.join(source, "site")
  if Dir.exist?(spa_dir)
    Dir.glob(File.join(spa_dir, "*.html")).each do |path|
      site.static_files << Jekyll::StaticFile.new(
        site, source, "site", File.basename(path)
      )
    end
  end

  # Register index JSON files
  %w[schemas_index.json resources_index.json].each do |json_file|
    json_path = File.join(source, json_file)
    next unless File.exist?(json_path)

    site.static_files << Jekyll::StaticFile.new(
      site, source, "", json_file
    )
  end
end
