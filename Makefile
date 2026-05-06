SHELL := /bin/bash
LUTAML_BUNDLE := BUNDLE_GEMFILE=Gemfile.lutaml

# Packages that build LXR but skip SPA generation (known xsdvi bugs)
SPA_SKIP  :=

all: configs lxr-spas _site

# Generate per-schema config files and index JSON
schemas_index.json: generate_configs.rb
	ruby generate_configs.rb

configs: schemas_index.json ;

# Build all LXR + SPA packages (using lutaml Gemfile)
lxr-spas: configs
	$(MAKE) build-all

build-all:
	$(MAKE) -j4 $(LXR_FILES) $(SPA_OK)

CONFIGS   := $(wildcard configs/*.yml)
LXR_FILES := $(patsubst configs/%.yml,build/%.lxr,$(CONFIGS))
SPA_FILES := $(patsubst configs/%.yml,site/%.html,$(CONFIGS))
SPA_OK    := $(filter-out $(foreach s,$(SPA_SKIP),site/$(s).html),$(SPA_FILES))

# Build a single LXR package from a config
build/%.lxr: configs/%.yml
	mkdir -p build
	$(LUTAML_BUNDLE) bundle exec lutaml-xsd build from-config $< \
		--output $@

# Generate a single SPA HTML from an LXR package
site/%.html: build/%.lxr
	mkdir -p site
	$(LUTAML_BUNDLE) bundle exec lutaml-xsd spa $< \
		--mode inlined \
		--output $@

# Build Jekyll site (copies SPA files from site/ into _site/)
_site: lxr-spas
	JEKYLL_ENV=production bundle exec jekyll build

# Dev server
serve:
	bundle exec jekyll serve

clean:
	rm -rf build site _site configs schemas_index.json

distclean: clean
	rm -rf schemas/_site

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git checkout main
	git submodule foreach git pull origin main

.PHONY: all configs build-all lxr-spas clean distclean serve update-init update-modules
