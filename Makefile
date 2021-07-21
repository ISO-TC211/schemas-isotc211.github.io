SHELL := /bin/bash

all: _site

clean: clean-schemas
	rm -rf _site build_source

schemas/_site:
	pushd schemas; \
	$(MAKE) all

build_source: schemas/_site
	mkdir -p $@; \
	cp -a source/* build_source; \
	cp -a schemas/_site build_source/schemas; \
	cp -a schemas/19* build_source; \
	mkdir -p build_source/_data; \
	cp schemas.yml build_source/_data;

_site: build_source
	bundle exec jekyll build

serve: _site
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git checkout master
	git submodule foreach git pull origin master

clean-schemas:
	$(MAKE) -f schemas/Makefile clean

.PHONY: all clean serve update-init update-modules
