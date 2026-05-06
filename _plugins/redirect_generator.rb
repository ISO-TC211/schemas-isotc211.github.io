# Generates HTML redirect pages from _data/redirects.yml
Jekyll::Hooks.register :site, :post_write do |site|
  redirects = site.data["redirects"]
  next if redirects.nil?

  redirects.each do |entry|
    from = entry["from"]
    to = entry["to"]
    next if from.nil? || to.nil?

    # Normalize: remove leading slash, add .html extension for directory paths
    rel_path = from.sub(%r{^/}, "")
    rel_path += "index.html" if rel_path.end_with?("/")
    rel_path += ".html" unless rel_path.end_with?(".html")

    dest = site.in_dest_dir(rel_path)
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
