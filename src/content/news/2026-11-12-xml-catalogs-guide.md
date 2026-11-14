---
layout: post
title:  "New guide: XML catalogs for working with ISO/TC 211 schemas"
date:   2026-11-12 12:00:00 +0800
categories: update
---

ISO/TC 211 schemas are served from a single, reliable, and permanent source —
this site — so `xsi:schemaLocation` attributes and `xsd:import` elements always
resolve to the normative schema documents. But when you work offline, when a
repository is temporarily unreachable, or when repeated downloads slow your
processing down, an XML catalog is the right tool for the job.

A new guide is now available in the
[Docs section](/docs/xml-catalogs/):
[**XML Catalogs**](/docs/xml-catalogs/).

The guide was authored by
[Heidi Vanparys](https://github.com/heidivanparys) (DK), supported by
[Tobias Spears](https://github.com/sptws001) (CA),
[Magnus Karge](https://github.com/magnusKarge) (NO), and
[Peter Parslow](https://github.com/PeterParslow) (GB).

## What the guide covers

**Mapping namespace URIs.** Using the catalog `uri` element to point an XML
namespace — for example
`https://schemas.isotc211.org/19115/-1/mdb/1.3` — at a local copy of the
schema document that declares it.

**Mapping schema locations.** Using the `system` element to redirect
`schemaLocation` URLs to local files, including a discussion of when `uri`
versus `system` entries are appropriate and how to support both for maximum
tool compatibility.

**A starter catalog for the geospatial domain.** Ready-to-adapt entries for
the core schemas that ISO/TC 211 schemas commonly reference: XML Schema,
`xml.xsd`, XLink, GML 3.2, and the ISO 19139 gco/gmd/gmx/gsr/gss/gts
schemas.

## Why it matters

XML validators, IDEs, and other tools fetch schema definitions automatically
from the URLs declared in instance documents. Local catalog mappings keep that
workflow working when connectivity does not cooperate, eliminate redundant
downloads, and avoid the errors and warnings that occur when the same schema
is loaded more than once from different locations.

The guide joins the [Docs section](/docs/), which collects practical guidance
for implementers of ISO/TC 211 schemas.

This action is performed by
[Ribose](https://www.ribose.com).
