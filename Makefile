SHELL := /bin/bash

all: _site

clean:
	rm -rf _site build_source

schemas/_site:
	pushd schemas; \
	bundle; \
	bundle exec hrma build documentation --workers 1

build_source:
	mkdir -p $@

build_source/.done: schemas/_site | build_source
	cp -a source/* build_source; \
	cp -a schemas/19* build_source; \
	cp -a schemas/Resources build_source; \
	cp -R schemas/_site/* build_source; \
	touch $@

build_source/_data/schemas.yml: schemas.yml | build_source
	mkdir -p $(dir $@); \
	cp $< $@

schemas.yml:

_site: build_source/.done build_source/_data/schemas.yml
	bundle exec jekyll build

serve: build_source/.done build_source/_data/schemas.yml
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git checkout main
	git submodule foreach git pull origin main

distclean: clean clean-schemas

clean-schemas:
	pushd schemas; \
	bundle; \
	bundle exec hrma build clean

.PHONY: all clean clean-schemas distclean serve update-init update-modules
