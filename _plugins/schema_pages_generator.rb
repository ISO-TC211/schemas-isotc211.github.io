# Generates per-standard landing pages and per-namespace dereference pages
# from schemas_index.json. These allow:
#   /19115/             → standard landing page listing all packages, parts, editions
#   /19115/-1/cit/1.3/  → namespace description page (dereferencing)
#
# URI conventions (ISO/TC 211 resolutions 857/858):
#   Namespace:  https://schemas.isotc211.org/{std}/-{part}/{ns}/{edition}.{major}
#   Location:   https://schemas.isotc211.org/{std}/-{part}/{ns}/{edition}.{major}.{minor}/{ns}.xsd
Jekyll::Hooks.register :site, :post_write do |site|
  index_path = site.in_dest_dir("schemas_index.json")
  unless File.exist?(index_path)
    Jekyll.logger.warn "SchemaPages:", "schemas_index.json not found — skipping page generation"
    next
  end

  packages = JSON.parse(File.read(index_path))

  # ── Per-standard pages ──
  by_standard = packages.group_by { |p| p["standard"] }

  by_standard.each do |std, pkgs|
    # Collect unique modules grouped by part
    parts = {}
    pkgs.each do |pkg|
      (pkg["xsd_paths"] || []).each do |path|
        if path =~ %r{schemas/\d+/([^/]+)/([^/]+)/([^/]+)/.+\.xsd$}
          part_dir, mod, full_ver = $1, $2, $3
          part_key = part_dir  # e.g. "-1", "-2", "-3", "-"
          parts[part_key] ||= {}
          ns_ver = full_ver.split('.')[0..1].join('.')
          ns_key = "#{std}/#{part_dir}/#{mod}/#{ns_ver}"
          parts[part_key][mod] ||= { "versions" => [], "ns_key" => ns_key, "part" => part_dir }
          parts[part_key][mod]["versions"] |= [full_ver]
          parts[part_key][mod]["packages"] ||= []
          parts[part_key][mod]["packages"] |= [pkg]
        end
      end
    end

    html = render_standard_page(site, std, pkgs, parts)
    write_page(site, "#{std}/index.html", html)
  end

  # ── Per-namespace dereference pages ──
  namespaces = {}

  packages.each do |pkg|
    (pkg["xsd_paths"] || []).each do |path|
      if path =~ %r{schemas/(\d+)/([^/]+)/([^/]+)/([^/]+)/(.+\.xsd)$}
        std, part_dir, mod, full_ver, filename = $1, $2, $3, $4, $5
        ns_ver = full_ver.split('.')[0..1].join('.')
        ns_key = "#{std}/#{part_dir}/#{mod}/#{ns_ver}"

        namespaces[ns_key] ||= {
          "standard" => std,
          "part" => part_dir,
          "module" => mod,
          "ns_version" => ns_ver,
          "xsd_files" => [],
          "package" => pkg,
        }

        namespaces[ns_key]["xsd_files"] |= [{ "name" => filename, "version" => full_ver }]
      end
    end
  end

  namespaces.each do |ns_key, ns_info|
    html = render_namespace_page(site, ns_info)
    write_page(site, "#{ns_key}/index.html", html)
  end

  Jekyll.logger.info "SchemaPages:", "Generated #{by_standard.size} standard pages + #{namespaces.size} namespace pages"
end

private

def render_standard_page(site, std, pkgs, parts)
  base = site.config["url"] || "https://schemas.isotc211.org"

  # Separate current and historical
  current_pkgs = pkgs.select { |p| p["status"] == "current" }
  historical_pkgs = pkgs.select { |p| p["status"] != "current" }

  # Sort parts: "-" first, then "-1", "-2", etc.
  sorted_parts = parts.keys.sort_by { |p| p == "-" ? "0" : p }

  parts_html = sorted_parts.map do |part_key|
    modules = parts[part_key].sort_by { |mod, _| mod }
    part_label = part_key == "-" ? "Standalone" : "Part #{part_key.sub('-', '')}"

    modules_html = modules.map do |mod, info|
      versions = info["versions"].sort.reverse
      latest_ns_ver = versions.first.split('.')[0..1].join('.')
      ns_url = "/#{std}/#{info["part"]}/#{mod}/#{latest_ns_ver}/"

      <<~HTML
        <a href="#{ns_url}" class="ns-card">
          <span class="ns-card__prefix">#{mod}</span>
          <span class="ns-card__versions">#{versions.join(', ')}</span>
          <span class="ns-card__path">#{std}/#{part_key}/#{mod}/</span>
        </a>
      HTML
    end.join("\n")

    <<~HTML
      <div class="part-section">
        <h3 class="part-title">#{part_label} <code>#{std}/#{part_key}/</code></h3>
        <div class="ns-grid">
          #{modules_html}
        </div>
      </div>
    HTML
  end.join("\n")

  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>ISO #{std} — schemas.isotc211.org</title>
      <link rel="canonical" href="#{base}/#{std}/">
      <style>#{standard_page_css}</style>
    </head>
    <body>
      <div class="page">
        <header class="header">
          <a href="/" class="header__home">&larr; All schemas</a>
          <span class="header__site">schemas.isotc211.org</span>
        </header>
        <main class="content">
          <h1 class="title">ISO #{std}</h1>

          #{current_pkgs.any? ? "<h2 class=\"section-title\">Current packages</h2>" : ""}
          #{current_pkgs.map { |p| render_pkg_card(p) }.join("\n")}

          #{historical_pkgs.any? ? "<details class=\"historical\"><summary class=\"section-title section-title--muted\">Historical packages (#{historical_pkgs.size})</summary>" : ""}
          #{historical_pkgs.map { |p| render_pkg_card(p) }.join("\n")}
          #{"</details>" if historical_pkgs.any?}

          <h2 class="section-title">Namespaces &amp; editions</h2>
          <div class="convention-box">
            <p>ISO/TC 211 XML schemas use the following URI pattern:</p>
            <code>https://schemas.isotc211.org/<em>{standard}</em>/<em>-{part}</em>/<em>{namespace}</em>/<em>{edition}.{major}</em>/<em>{namespace}</em>.xsd</code>
          </div>

          #{parts_html}
        </main>
      </div>
    </body>
    </html>
  HTML
end

def render_pkg_card(pkg)
  spa_link = pkg["has_spa"] && pkg["browser_path"] ? "<a href=\"/#{pkg["browser_path"]}\" class=\"card__link\">Browse schema &rarr;</a>" : ""
  type_badge = pkg["type"] == "json" ? '<span class="badge badge--json">JSON</span>' : ""

  <<~HTML
    <div class="card">
      <div class="card__top">
        <span class="card__name">#{esc_html(pkg["name"])}</span>
        #{type_badge}
        <span class="badge badge--#{pkg["status"]}">#{pkg["status"]}</span>
      </div>
      <p class="card__desc">#{esc_html(pkg["description"])}</p>
      #{spa_link}
    </div>
  HTML
end

def render_namespace_page(site, ns_info)
  base = site.config["url"] || "https://schemas.isotc211.org"
  std = ns_info["standard"]
  part = ns_info["part"]
  mod = ns_info["module"]
  ns_ver = ns_info["ns_version"]
  pkg = ns_info["package"]
  xsd_files = ns_info["xsd_files"].sort_by { |f| f["name"] }

  namespace_uri = "https://schemas.isotc211.org/#{std}/#{part}/#{mod}/#{ns_ver}"

  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>#{mod} namespace (#{namespace_uri})</title>
      <link rel="canonical" href="#{base}/#{std}/#{part}/#{mod}/#{ns_ver}/">
      <style>#{standard_page_css}</style>
    </head>
    <body>
      <div class="page">
        <header class="header">
          <a href="/#{std}/" class="header__home">&larr; ISO #{std}</a>
          <a href="/" class="header__site">schemas.isotc211.org</a>
        </header>
        <main class="content">
          <div class="ns-header">
            <span class="ns-header__prefix">#{mod}</span>
            <h1 class="ns-header__title">#{namespace_uri}</h1>
          </div>

          <dl class="ns-details">
            <dt>Standard</dt>
            <dd><a href="/#{std}/">ISO #{std}</a></dd>

            <dt>Part</dt>
            <dd>#{part == '-' ? 'Standalone' : "Part #{part.sub('-', '')}"}</dd>

            <dt>Namespace prefix</dt>
            <dd><code>#{mod}</code></dd>

            <dt>Namespace version</dt>
            <dd><code>#{ns_ver}</code></dd>

            <dt>Package</dt>
            <dd>#{esc_html(pkg["name"])}</dd>

            <dt>Status</dt>
            <dd><span class="badge badge--#{pkg["status"]}">#{pkg["status"]}</span></dd>

            <dt>Description</dt>
            <dd>#{esc_html(pkg["description"])}</dd>
          </dl>

          <h2 class="section-title">Schema locations</h2>
          <p class="xsd-hint">The normative XML schema files for this namespace:</p>
          <ul class="xsd-list">
            #{xsd_files.map { |f|
              schema_url = "https://schemas.isotc211.org/#{std}/#{part}/#{mod}/#{f["version"]}/#{f["name"]}"
              "<li>
                <a href=\"/schemas/#{std}/#{part}/#{mod}/#{f["version"]}/#{f["name"]}\">#{f["name"]}</a>
                <span class=\"xsd-url\">#{schema_url}</span>
              </li>"
            }.join("\n")}
          </ul>

          #{pkg["has_spa"] && pkg["browser_path"] ? "<a href=\"/#{pkg["browser_path"]}\" class=\"card__link card__link--large\">Browse interactive schema &rarr;</a>" : ""}
        </main>
      </div>
    </body>
    </html>
  HTML
end

def write_page(site, rel_path, html)
  dest = site.in_dest_dir(rel_path)
  FileUtils.mkdir_p(File.dirname(dest))
  File.write(dest, html)
end

def esc_html(str)
  str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
end

def standard_page_css
  <<~CSS
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', system-ui, -apple-system, sans-serif; background: #fff; color: #0f172a; line-height: 1.6; -webkit-font-smoothing: antialiased; }
    @media (prefers-color-scheme: dark) {
      body { background: #0f172a; color: #f8fafc; }
      .header { background: #0f172a; border-color: #1e293b; }
      .header__home, .header__site { color: #94a3b8; }
      .header__home:hover { color: #66a3e0; }
      .card { background: #1e293b; border-color: #334155; }
      .card:hover { border-color: #3385d6; }
      .card__name { color: #f1f5f9; }
      .card__desc { color: #94a3b8; }
      .card__link { color: #66a3e0; }
      .section-title { color: #f8fafc; border-color: #1e293b; }
      .section-title--muted { color: #64748b; }
      .badge--current { background: #052e16; color: #6ee7b7; border-color: #064e3b; }
      .badge--historical { background: #1e293b; color: #94a3b8; border-color: #334155; }
      .badge--json { background: #2e1065; color: #c084fc; border-color: #581c87; }
      .ns-card { background: #1e293b; border-color: #334155; color: #e2e8f0; }
      .ns-card:hover { border-color: #3385d6; }
      .ns-card__prefix { color: #66a3e0; }
      .ns-card__path { color: #64748b; }
      .ns-card__versions { color: #94a3b8; }
      .ns-header__prefix { color: #66a3e0; }
      .ns-header__title { color: #cbd5e1; }
      .ns-details dt { color: #94a3b8; }
      .ns-details dd { color: #e2e8f0; }
      .ns-details a { color: #66a3e0; }
      .ns-details code { background: #0f172a; color: #e2e8f0; }
      .xsd-list a { color: #66a3e0; }
      .xsd-url { color: #64748b; }
      .convention-box { background: #1e293b; border-color: #334155; }
      .convention-box code em { color: #94a3b8; }
      .part-title { color: #f8fafc; }
      .part-title code { background: #0f172a; color: #e2e8f0; }
      .historical { border-color: #334155; }
      .xsd-hint { color: #94a3b8; }
    }

    .page { min-height: 100vh; }
    .header {
      position: sticky; top: 0; z-index: 50;
      display: flex; align-items: center; justify-content: space-between;
      padding: 0.75rem 1.5rem;
      background: #fff; border-bottom: 1px solid #e2e8f0;
      font-size: 0.8125rem;
    }
    .header__home, .header__site { color: #64748b; text-decoration: none; }
    .header__home:hover { color: #0061ad; }
    .header__site { font-weight: 600; }

    .content { max-width: 48rem; margin: 0 auto; padding: 2.5rem 1.25rem 4rem; }

    .title {
      font-size: clamp(1.75rem, 4vw, 2.5rem);
      font-weight: 700; letter-spacing: -0.025em;
      margin-bottom: 2rem;
    }

    .section-title {
      font-size: 1rem; font-weight: 700; color: #334155;
      margin: 2rem 0 1rem;
      padding-bottom: 0.5rem; border-bottom: 1px solid #e2e8f0;
    }
    .section-title--muted { color: #94a3b8; }

    .historical { border: 1px solid #e2e8f0; border-radius: 0.5rem; padding: 0 1rem; margin-bottom: 1rem; }
    .historical summary { cursor: pointer; padding: 0.75rem 0; }

    .card {
      padding: 1.25rem; margin-bottom: 0.75rem;
      background: #fff; border: 1px solid #e2e8f0; border-radius: 0.75rem;
      transition: border-color 0.2s;
    }
    .card:hover { border-color: #0061ad; }
    .card__top { margin-bottom: 0.5rem; display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap; }
    .card__name { font-weight: 600; font-size: 0.9375rem; }
    .card__desc { font-size: 0.8125rem; color: #64748b; margin-bottom: 0.5rem; }
    .card__link {
      display: inline-flex; align-items: center; gap: 0.25rem;
      font-size: 0.8125rem; font-weight: 600; color: #0061ad; text-decoration: none;
    }
    .card__link:hover { text-decoration: underline; }
    .card__link--large { font-size: 1rem; margin-top: 1.5rem; display: inline-flex; }

    .badge {
      display: inline-flex; padding: 0.125rem 0.5rem;
      font-size: 0.625rem; font-weight: 600; border-radius: 9999px;
      text-transform: uppercase; letter-spacing: 0.05em; border: 1px solid;
    }
    .badge--current { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
    .badge--historical { background: #f8fafc; color: #475569; border-color: #e2e8f0; }
    .badge--json { background: #faf5ff; color: #6b21a8; border-color: #e9d5ff; }

    .convention-box {
      padding: 1rem 1.25rem; margin-bottom: 1.5rem;
      background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 0.5rem;
      font-size: 0.8125rem; color: #64748b;
    }
    .convention-box p { margin-bottom: 0.5rem; }
    .convention-box code {
      display: block; font-size: 0.8125rem; word-break: break-all;
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
    }
    .convention-box code em { color: #0061ad; font-style: normal; font-weight: 600; }

    .part-section { margin-bottom: 2rem; }
    .part-title {
      font-size: 0.9375rem; font-weight: 600; color: #334155;
      margin-bottom: 0.75rem;
    }
    .part-title code {
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      font-size: 0.8125rem; padding: 0.125rem 0.5rem;
      background: #f1f5f9; border-radius: 0.25rem; color: #64748b;
    }

    .ns-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(12rem, 1fr)); gap: 0.5rem; }
    .ns-card {
      display: flex; flex-direction: column; gap: 0.25rem;
      padding: 1rem; background: #fff; border: 1px solid #e2e8f0;
      border-radius: 0.5rem; text-decoration: none; color: #0f172a;
      transition: border-color 0.2s;
    }
    .ns-card:hover { border-color: #0061ad; }
    .ns-card__prefix {
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      font-size: 1.125rem; font-weight: 700; color: #0061ad;
    }
    .ns-card__path {
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      font-size: 0.6875rem; color: #94a3b8;
    }
    .ns-card__versions { font-size: 0.75rem; color: #64748b; }

    .ns-header { margin-bottom: 2rem; }
    .ns-header__prefix {
      display: inline-block;
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      font-size: 1.5rem; font-weight: 700; color: #0061ad;
      margin-bottom: 0.5rem;
    }
    .ns-header__title {
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      font-size: 1rem; font-weight: 400; color: #334155;
      word-break: break-all;
    }

    .ns-details {
      display: grid; grid-template-columns: auto 1fr; gap: 0.5rem 1rem;
      margin-bottom: 2rem; font-size: 0.875rem;
    }
    .ns-details dt { font-weight: 600; color: #64748b; }
    .ns-details dd { color: #0f172a; }
    .ns-details a { color: #0061ad; text-decoration: none; }
    .ns-details a:hover { text-decoration: underline; }
    .ns-details code {
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      font-size: 0.8125rem; padding: 0.0625rem 0.375rem;
      background: #f1f5f9; border-radius: 0.25rem;
    }

    .xsd-hint { font-size: 0.8125rem; color: #64748b; margin-bottom: 0.75rem; }
    .xsd-list { list-style: none; padding: 0; }
    .xsd-list li { margin-bottom: 0.375rem; }
    .xsd-list a {
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      font-size: 0.8125rem; color: #0061ad; text-decoration: none;
      padding: 0.375rem 0.75rem; display: inline-block;
      border-radius: 0.25rem; transition: background 0.15s;
    }
    .xsd-list a:hover { background: #f1f5f9; text-decoration: underline; }
    .xsd-url {
      display: block; font-size: 0.6875rem; color: #94a3b8;
      padding-left: 0.75rem;
      font-family: 'JetBrains Mono', 'Noto Sans Mono', Consolas, monospace;
      word-break: break-all;
    }
  CSS
end
