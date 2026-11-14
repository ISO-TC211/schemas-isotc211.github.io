---
layout: post
title:  Persistent URLs for ISO/TC 211 codelist definitions
date:   2026-06-10 12:00:00 +0800
categories: update
---

ISO/TC 211 codelist definitions now have a single, stable, dereferenceable
home on `schemas.isotc211.org`.

## The problem

ISO/TC 211 schemas use typed enumerations whose valid values are defined in
codelist catalogues — XML files that list each code, its identifier, and its
definition. For years these catalogues had no persistent URL. The files moved
between directories, URLs broke, and external communities — INSPIRE validators,
DCAT specification authors, linked-data practitioners — could not rely on a
stable address.

See the related issues:

* [INSPIRE-MIF/helpdesk-validator#479](https://github.com/INSPIRE-MIF/helpdesk-validator/issues/479) — codelist URLs returning 404
* [w3c/dxwg#975](https://github.com/w3c/dxwg/issues/975) — DCAT spec needs readable codelist links
* [ISO-TC211/XML#205](https://github.com/ISO-TC211/XML/issues/205) — no canonical URI pattern for individual code values

## The solution

The comprehensive codelist catalogue (`codelists.xml`) — covering all ISO/TC 211
standards from 19107 through 19163 — has been moved to a stable, cross-cutting
location:

```
https://schemas.isotc211.org/resources/codelists/codelists.xml
```

Every codelist and every individual code value is addressable via a fragment
identifier:

```
https://schemas.isotc211.org/resources/codelists/codelists.xml#ISO19115-1.1.cit.CI_RoleCode
https://schemas.isotc211.org/resources/codelists/codelists.xml#ISO19115-1.1.cit.CI_RoleCode_custodian
```

### Backward compatibility

The previous URL (`/Resources/codelists.xml`) is preserved via a transparent
file-copy redirect — XML parsers that dereference `codeList` attributes get the
real XML content, not an HTML redirect page.

## Browseable HTML pages

70 codelist definitions are now available as interactive HTML pages at
[/resources/codelists/](/resources/codelists/), generated directly from the
source XML. Each page shows the codelist identifier, definition, canonical URI,
and a table of all defined values.

For example, [CI\_RoleCode](/resources/codelists/ISO19115-1.1.cit.CI-RoleCode/)
lists all responsibility role codes from ISO 19115-1.

## What changed

* Moved `codelists.xml` from `19115/resources/codelists/` to the
  cross-cutting `resources/codelists/` directory
* Updated 515 internal cross-references and 421 `codeList` URLs in example
  files to the new canonical path
* Archived superseded files (`codelists1.xml`, `19157/-1/codelists.xml`)
* Added a [Jekyll generator](https://github.com/ISO-TC211/schemas-isotc211.github.io)
  that parses the catalogue XML and produces static HTML pages
* Added "Codelists" to the site header navigation

This action is performed by
[Ribose](https://www.ribose.com).
