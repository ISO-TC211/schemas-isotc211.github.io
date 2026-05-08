# Generates redirect pages from _data/redirects.yml
# For data files (.xsd, .xml, etc.): copies the actual target file to the old path
#   so XML parsers get real content (they can't follow HTML redirects).
# For HTML/directory paths: generates an HTML meta-refresh redirect page.
require_relative "schema_site/models"

Jekyll::Hooks.register :site, :post_write do |site|
  redirects = site.data["redirects"]
  next if redirects.nil?

  redirects.each do |entry|
    from = entry["from"]
    to = entry["to"]
    next if from.nil? || to.nil?

    rel_path = from.sub(%r{^/}, "")
    ext = File.extname(rel_path)

    if SchemaSite::DATA_EXTENSIONS.include?(ext.downcase)
      # Data file: copy actual target to old path
      target = site.in_dest_dir(to.sub(%r{^/}, ""))
      if File.exist?(target) && !File.directory?(target)
        dest = site.in_dest_dir(rel_path)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(target, dest)
      end
    else
      # HTML/directory path: generate redirect page
      html_path = rel_path
      html_path += "index.html" if html_path.end_with?("/")
      html_path += ".html" unless html_path.end_with?(".html")
      dest = site.in_dest_dir(html_path)

      FileUtils.mkdir_p(File.dirname(dest))
      File.write(dest, <<~HTML)
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta http-equiv="refresh" content="0; url=#{to}">
          <link rel="canonical" href="#{to}">
          <title>Redirecting…</title>
        </head>
        <body>
          <p>This resource has moved to <a href="#{to}">#{to}</a>.</p>
        </body>
        </html>
      HTML
    end
  end
end
