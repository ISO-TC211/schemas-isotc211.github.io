SHELL := /bin/bash
LUTAML_BUNDLE := BUNDLE_GEMFILE=schemas/Gemfile BUNDLE_PATH=vendor/bundle-lutaml

all: configs lxr-spas site

configs:
	ruby generate_configs.rb
	BUNDLE_GEMFILE=schemas/Gemfile bundle exec ruby scripts/export-codelists.rb

# Build LXR packages + SPA pages (Ruby pipeline, unchanged)
lxr-spas: configs
	@GEM_DIR=$$($(LUTAML_BUNDLE) bundle show lutaml-jsonschema 2>/dev/null) && \
		[ -d "$$GEM_DIR/frontend/dist" ] || { cd "$$GEM_DIR/frontend" && npm install && npm run build; } || true
	@XSD_DIR=$$($(LUTAML_BUNDLE) bundle show lutaml-xsd 2>/dev/null) && \
		[ -d "$$XSD_DIR/frontend/dist" ] || { cd "$$XSD_DIR/frontend" && npm install && npm run build; } || true
	$(MAKE) -j4 $(LXR_FILES) $(SPA_FILES)

CONFIGS   := $(wildcard configs/*.yml)
LXR_FILES := $(patsubst configs/%.yml,build/%.lxr,$(CONFIGS))
SPA_FILES :=

# Build the Astro site (Astro reads schemas_index.json etc. from configs step)
site: lxr-spas
	npm ci
	npm run build

serve:
	npm run dev

clean:
	rm -rf build site dist public configs schemas_index.json resources_index.json codelists_index.json node_modules/.astro

update:
	git -C schemas pull || git clone --depth 1 https://github.com/ISO-TC211/schemas.git schemas

.PHONY: all configs lxr-spas site serve clean update
