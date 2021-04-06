SHELL := /bin/bash
#rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
#XSDSRC := $(call rwildcard,schemas/,[a-z][a-z][a-z].xsd)
#XSDSRCALL := $(call rwildcard,schemas/,*.xsd)
XSDSRC := $(shell yq e .source.schemas schemas.yml  | cut -c 3-)
XSDDOC := $(patsubst schemas/%.xsd,doc/schemas/%/index.html,$(XSDSRC))

XSDVIPATH := ${CURDIR}/xsdvi/xsdvi.jar
XSLT_FILE := ${CURDIR}/xsl/xs3p.xsl
XSLT_FILE_MERGE := ${CURDIR}/xsl/xsdmerge.xsl

all: _site _xsddoc

clean:
	rm -rf _site build_source

_xsddoc: $(XSDDOC)

xsdvi/xsdvi.zip:
	mkdir -p $(dir $@)
	curl -sSL https://sourceforge.net/projects/xsdvi/files/latest/download > $@

$(XSDVIPATH): xsdvi/xercesImpl.jar
	curl -sSL https://github.com/metanorma/xsdvi/releases/download/v1.0/xsdvi-1.0.jar > $@

$(XSLT_FILE):
	mkdir -p $(dir $@)
	curl -sSL https://raw.githubusercontent.com/unitsml/schemas/master/xsl/xs3p.xsl > $@

$(XSLT_FILE_MERGE):
	mkdir -p $(dir $@)
	curl -sSL https://raw.githubusercontent.com/unitsml/schemas/master/xsl/xsdmerge.xsl > $@


xsdvi/xercesImpl.jar: xsdvi/xsdvi.zip
	unzip -p $< dist/lib/xercesImpl.jar > $@

doc/%/index.html: %.xsd $(XSDVIPATH) $(XSLT_FILE) $(XSLT_FILE_MERGE)
	mkdir -p $(dir $@)diagrams; \
	java -jar $(XSDVIPATH) $(CURDIR)/$< -rootNodeName all -oneNodeOnly -outputPath $(dir $@)diagrams; \
	xsltproc --nonet --stringparam rootxsd $< --output $@.tmp $(XSLT_FILE_MERGE) $<;\
	xsltproc --nonet --param title "'Schema Documentation $(notdir $*)'" \
		--output $@ $(XSLT_FILE) $@.tmp;\
	rm $@.tmp

build_source:
	mkdir -p $@; \
	cp -a source/* build_source; \
	cp -a schemas/* build_source; \

_site: build_source
	bundle exec jekyll build

serve: _site
	bundle exec jekyll serve

update-init:
	git submodule update --init

update-modules:
	git submodule foreach git pull origin master

.PHONY: all clean serve update-init update-modules
