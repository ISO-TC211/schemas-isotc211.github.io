# frozen_string_literal: true

source "https://rubygems.org"

gem "jekyll", "~> 4.3"
if ENV["CI"] || !File.directory?(File.expand_path("../jekyll-theme-isotc211", __dir__))
  gem "jekyll-theme-isotc211"
else
  gem "jekyll-theme-isotc211", path: "../jekyll-theme-isotc211"
end

group :jekyll_plugins do
  gem "jekyll-vite"
  gem "jekyll-feed"
  gem "jekyll-redirect-from"
end

gem "lutaml-xsd", "~> 1.1"
gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
gem "lutaml-jsonschema"
gem "moxml"
gem "canon"
gem "webrick"
