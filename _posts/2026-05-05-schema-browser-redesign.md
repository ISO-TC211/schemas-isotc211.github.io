---
layout: post
title:  Schema browser redesigned with data-driven architecture and resource catalog
date:   2026-05-05 12:00:00 +0800
categories: update
---
The ISO/TC 211 Schemas site has been redesigned with a modern interface,
fully data-driven architecture, and a comprehensive resource catalog.

## What's new

* **Interactive schema browsers** --
Each schema package now has a dedicated interactive browser powered by
[LutaML XSD](https://lutaml.github.io/lutaml-xsd/),
providing full listings of elements, complex types, simple types,
and attribute groups with cross-references.

* **Data-driven resource catalog** --
All resources — XSLT transforms, Schematron validation rules, XML and JSON examples,
codelist dictionaries, and download packages — are now auto-discovered from the
filesystem and presented in a filterable catalog at [/resources/](/resources/).

* **Reorganized schema repository** --
The underlying [schemas repository](https://github.com/ISO-TC211/schemas)
has been restructured with consistent directory naming (`standard/-part/module/version/`),
separated examples, consolidated per-standard resources, and proper ZIP bundles.

* **Supported standards** --
The site currently provides schema browsers for:

  * ISO 19103 — Conceptual Schema Language
  * ISO 19110 — Feature Cataloguing
  * ISO 19111 — Referencing by Coordinates
  * ISO 19115-1 — Metadata Fundamentals
  * ISO 19115-2 — Metadata for Imagery
  * ISO 19115-3 — Metadata XML Schema
  * ISO 19123-2 — Coverages
  * ISO 19130-2 — Sensor Models
  * ISO 19135 — Procedures for Registration
  * ISO 19136 — Geography Markup Language
  * ISO 19139 — Metadata XML Implementation
  * ISO 19155 — Place Identifier
  * ISO 19157-1 — Data Quality
  * ISO 19157-2 — Data Quality XML Schema
  * ISO 19165-1 — Preservation of Geospatial Data

Additional standards will be added as they become available.

This action is performed by
[Ribose](https://www.ribose.com).
