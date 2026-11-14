---
layout: post
title:  Discoverable resources for every ISO/TC 211 standard
date:   2026-06-11 12:00:00 +0800
categories: update
---

Every ISO/TC 211 standard comes with more than just a schema file. There are
codelist dictionaries, example instances, Schematron validation rules, XSLT
transforms, and downloadable packages. Until now these resources were scattered
across the repository — visible only if you knew the right directory path.

As of today, all resources are discoverable through the site itself.

## What changed

**The homepage now has a Resources section.** Six cards link to the major
resource categories: [Codelist Catalogues](/resources/codelists/), Example
Instances, XSLT Transforms, Schematron Rules, Download Packages, and the raw
GitHub repository. Each card links directly to the filtered resource catalog.

**The resource catalog is filterable.** The [/resources/](/resources/) page
lets you filter by resource type and by standard. Looking for all Schematron
rules for ISO 19115? Two clicks. Looking for XML examples for ISO 19157? Same.

**Per-standard pages show their resources.** Each standard listing page (for
example, [ISO 19115-1](/19115/-1/)) shows a resources section with counts and
direct links to that standard's codelists, examples, transforms, and bundles.

**The navigation provides clear paths.** The header nav now includes
About, Resources, Codelists, and News — giving every major section a top-level
entry point.

## Why it matters

ISO/TC 211 schemas are used by a wide range of communities — national
geospatial agencies, INSPIRE implementers, OGC standards developers, and
metadata tool builders. These users need more than the XSD file. They need
to know what values a codelist allows, where to find example instances, and
whether Schematron rules exist for a given module.

Making these resources discoverable means:

* **Implementers** can find example instances and codelist values without
  digging through the repository
* **Validators** can locate Schematron rules and understand constraints beyond
  XSD
* **Tool developers** can discover transforms for migrating between versions
* **Standard editors** can see all resources for their standard in one place

## The full picture

The site now provides three complementary ways to find resources:

1. **Homepage cards** — quick access to the six major resource categories
2. **Resource catalog** — searchable and filterable by standard and type
3. **Standard pages** — resources listed alongside their schema packages

Combined with yesterday's [persistent codelist URLs](/update/2026/06/10/codelist-catalogues.html),
every category of ISO/TC 211 resource now has a stable, browseable home.

This action is performed by
[Ribose](https://www.ribose.com).
