---
layout: post
title:  Schema browser redesigned with data-driven architecture and resource catalog
date:   2026-05-05 12:00:00 +0800
categories: update
---
The ISO/TC 211 Schemas site has been redesigned with a modern interface,
fully data-driven architecture, and a comprehensive resource catalog.

## What's new

* **Interactive XSD schema browsers** --
Each XML schema package now has a dedicated interactive browser powered by
[LutaML XSD](https://lutaml.github.io/lutaml-xsd/),
providing full listings of elements, complex types, simple types,
and attribute groups with cross-references.

* **Interactive JSON schema browsers** --
JSON schema packages now have their own interactive browsers powered by
[LutaML JSON Schema](https://github.com/lutaml/lutaml-jsonschema/),
showing schema definitions, properties, references, and example data.

* **Data-driven resource catalog** --
All resources — XSLT transforms, Schematron validation rules, XML and JSON examples,
codelist dictionaries, and download packages — are now auto-discovered from the
filesystem and presented in a filterable catalog at [/resources/](/resources/).

* **Reorganized schema repository** --
The underlying [schemas repository](https://github.com/ISO-TC211/schemas)
has been restructured with consistent directory naming (`standard/-part/module/version/`),
separated examples, consolidated per-standard resources, and proper ZIP bundles.

## URL structure

All schemas are served at **canonical top-level URLs** with no `/schemas/` prefix.
This is the URL pattern that XML parsers, validators, and `schemaLocation` attributes
rely on.

### XML namespaces

```
https://schemas.isotc211.org/{standard}/{part}/{module}/{major}.{minor}
```

* `https://schemas.isotc211.org/19115/-1/cit/1.3` — ISO 19115-1 Citation module
* `https://schemas.isotc211.org/19136/-/gml/1.0` — ISO 19136 GML
* `https://schemas.isotc211.org/19157/-2/mdq/1.0` — ISO 19157-2 Data Quality measures

### XML Schema files (XSD)

```
https://schemas.isotc211.org/{standard}/{part}/{module}/{version}/{module}.xsd
```

* `https://schemas.isotc211.org/19115/-1/cit/1.3.0/cit.xsd`
* `https://schemas.isotc211.org/19136/-/gml/1.0/gml.xsd`
* `https://schemas.isotc211.org/19139/-/gco/1.0/gco.xsd`

### JSON Schema files

```
https://schemas.isotc211.org/json/{standard}/{part}/{module}/{version}/{module}.json
```

* `https://schemas.isotc211.org/json/19115/-4/mdj/1.0.0/mdj.json`
* `https://schemas.isotc211.org/json/19123/-2/cis/1.2/coverage-schema.json`
* `https://schemas.isotc211.org/json/19157/-1/dqc/1.0.0/dqc.json`

### Interactive schema browsers

```
https://schemas.isotc211.org/{standard}/{part}/{module}/{version}/browse/
```

### Namespace hub pages

```
https://schemas.isotc211.org/{standard}/{part}/{module}/{version}/
```

### Supporting resources

```
/{standard}/{part}/{module}/{version}/examples/...     — XML examples
/json/{standard}/{part}/{module}/{version}/examples/... — JSON examples
/{standard}/resources/transforms/...                    — XSLT transforms
/{standard}/resources/codelists/...                     — Codelist dictionaries
/{standard}/resources/bundles/...                       — Download packages
```

### Legacy paths

Some schemas were previously available at different paths (e.g., without
the part number, or with a `/schemas/` prefix). These old paths are
redirected to the canonical URLs above. XML data files are served as
actual file copies at the old path (since XML parsers cannot follow
HTML redirects).

## Supported standards

The site currently provides schema browsers for:

| Standard | XSD | JSON |
|----------|-----|------|
| ISO 19103 — Conceptual Schema Language | ✓ | |
| ISO 19110 — Feature Cataloguing | ✓ | |
| ISO 19111 — Referencing by Coordinates | ✓ | |
| ISO 19115-1 — Metadata Fundamentals | ✓ | |
| ISO 19115-2 — Metadata for Imagery | ✓ | |
| ISO 19115-3 — Metadata XML Schema | ✓ | |
| ISO 19115-4 — Metadata JSON Encoding | | ✓ |
| ISO 19123-2 — Coverages | ✓ | ✓ |
| ISO 19130-3 — Sensor Model Types | ✓ | |
| ISO 19131 — Data Product Specification | ✓ | |
| ISO 19135 — Procedures for Registration | ✓ | |
| ISO 19136 — Geography Markup Language | ✓ | |
| ISO 19139 — Metadata XML Implementation | ✓ | |
| ISO 19155 — Place Identifier | ✓ | |
| ISO 19157 — Data Quality | ✓ | |
| ISO 19157-1 — Data Quality Measures JSON | | ✓ |
| ISO 19157-2 — Data Quality XML Schema | ✓ | |
| ISO 19163 — Imagery Gridded Data | ✓ | |
| ISO 19165 — Geographic Privilege Management | ✓ | |

Additional standards will be added as they become available.

This action is performed by
[Ribose](https://www.ribose.com).
