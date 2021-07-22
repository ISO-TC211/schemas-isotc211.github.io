SHELL := /bin/bash

all: _site

clean: clean-schemas
	rm -rf _site build_source

schemas/_site:
	pushd schemas; \
	$(MAKE) all

build_source:
	mkdir -p $@

build_source/schemas/.done: schemas/_site | build_source
	mkdir -p $(dir $@); \
	cp -a source/* build_source; \
	cp -R schemas/_site/* build_source/schemas; \
	cp -a schemas/19* build_source; \
	touch $@

build_source/_data/schemas.yml: schemas.yml | build_source
	mkdir -p $(dir $@); \
	cp $< $@

schemas.yml:

_site: build_source/schemas/.done build_source/_data/schemas.yml
	bundle exec jekyll build

serve: _site
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git checkout master
	git submodule foreach git pull origin master

clean-schemas:
	pushd schemas; \
	$(MAKE) clean

.PHONY: all clean clean-schemas serve update-init update-modules
