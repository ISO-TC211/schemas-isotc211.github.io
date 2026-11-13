---
layout: page
title: XML Catalogs
permalink: /docs/xml-catalogs/
---

<section class="page-section">
  <div class="page-section__inner doc-content" markdown="1">

# XML Catalogs

An official XML schema repository, such as those maintained by ISO/TC 211 and
OGC, offers users a single, reliable, and permanent source for normative XML
schema documents. `xsi:schemaLocation` attributes in XML instance documents can
then reference the files in those official repositories. The ISO/TC 211 XML
schema documents also use `xsd:import` elements that have a `schemaLocation`
attribute, explicitly pointing to normative imported schema documents. Because
the exact locations of the used schemas are specified, XML validators, IDEs,
and other tools to fetch the correct schema definitions automatically.

However, using local copies of normative XML schemas may be preferred or
required in certain situations. Users might need to work offline, a schema
repository could be temporarily unavailable, and repeated downloads of the same
schema documents could add unnecessary overhead and slow down processing. An
[XML catalog](https://www.xmlcatalogs.org/catalogs-1.1.html) addresses these
concerns. XML catalogs also help avoid errors or warnings that occur when an
XML parser loads the same schema more than once, from different locations.

An XML catalog can be used to map:

1. a URI identifying an
   [XML namespace](https://www.w3.org/TR/xml-names/) to the physical location of
   a local copy of the
   [XML schema document](https://www.w3.org/TR/xmlschema-1/) describing that
   namespace;
2. a URI identifying a schema location to the physical location of a local copy
   of that schema document.

The sections below show concrete examples.

> **Important**
>
> An XML catalog maps to *local* copies of XML schema documents, which means
> catalog files are not portable. Always adjust the local file paths in your
> XML catalog so they correspond to the locations on your own file system.
{: .doc-callout .doc-callout--important }

## Mapping namespace URIs

A
[`uri` element](https://www.xmlcatalogs.org/catalogs-1.1.html#s.uri) maps a URI
identifying an XML namespace to the physical location of a local copy of the
schema document describing that namespace.

**`uri` element**
{: .doc-caption }

```xml
<uri name="xml_namespace_uri"
     uri="file:///path/to/local/copy/of/schema.xsd"/>
```

The `name` attribute contains the XML namespace URI.

The `uri` attribute identifies the actual, physical location of a local copy of
the corresponding XML schema document. The value of the `uri` attribute is
typically expressed as a
[file URI](https://www.rfc-editor.org/info/rfc8089).

**XML instance document declaring namespaces**
{: .doc-caption }

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mdb:MD_Metadata xmlns:cit="https://schemas.isotc211.org/19115/-1/cit/1.3"
                 xmlns:gco="https://schemas.isotc211.org/19103/-/gco/1.2"
                 xmlns:lan="https://schemas.isotc211.org/19115/-1/lan/1.3"
                 xmlns:mcc="https://schemas.isotc211.org/19115/-1/mcc/1.3"
                 xmlns:mdb="https://schemas.isotc211.org/19115/-1/mdb/1.3"
                 xmlns:mri="https://schemas.isotc211.org/19115/-1/mri/1.3"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <!-- ... -->
</mdb:MD_Metadata>
```

**XML schema document declaring and importing
([`xsd:import`](https://www.w3.org/TR/xmlschema-1/#element-import)) namespaces**
{: .doc-caption }

```xml
<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://www.w3.org/2001/XMLSchema"
        xmlns:cit="https://schemas.isotc211.org/19115/-1/cit/1.3"
        xmlns:gco="https://schemas.isotc211.org/19103/-/gco/1.2"
        xmlns:lan="https://schemas.isotc211.org/19115/-1/lan/1.3"
        targetNamespace="https://schemas.isotc211.org/19115/-1/lan/1.3"
        elementFormDefault="qualified"
        version="1.3.0">
    <import namespace="https://schemas.isotc211.org/19103/-/gco/1.2"/>
    <import namespace="https://schemas.isotc211.org/19115/-1/cit/1.3"/>
    <!-- ... -->
</schema>
```

> **Note**
>
> The example XML catalogs assume the following directory layout on the local
> machine. Each subdirectory mirrors the structure of the original website.
>
> ```text
> C:\XMLschemas
> +---schemas.isotc211.org
> +---schemas.opengis.net
> \---www.w3.org
> ```
{: .doc-callout .doc-callout--note }

**XML catalog mapping XML namespace names to local copies of schema documents**
{: .doc-caption }

```xml
<?xml version="1.0" encoding="UTF-8"?>
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
    <uri name="https://schemas.isotc211.org/19115/-1/cit/1.3"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/cit/1.3.0/cit.xsd"/>
    <uri name="https://schemas.isotc211.org/19103/-/gco/1.2"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19103/-/gco/1.2.0/gco.xsd"/>
    <uri name="https://schemas.isotc211.org/19115/-1/lan/1.3"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/lan/1.3.0/lan.xsd"/>
    <uri name="https://schemas.isotc211.org/19115/-1/mcc/1.3"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/mcc/1.3.0/mcc.xsd"/>
    <uri name="https://schemas.isotc211.org/19115/-1/mdb/1.3"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/mdb/1.3.1/mdb.xsd"/>
    <uri name="https://schemas.isotc211.org/19115/-1/mri/1.3"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/mri/1.3.0/mri.xsd"/>
    <uri name="http://www.w3.org/2001/XMLSchema-instance"
         uri="file:///C:/XMLschemas/www.w3.org/2001/XMLSchema-instance.xsd"/>
</catalog>
```

## Mapping URIs identifying schema locations

A
[`system` element](https://www.xmlcatalogs.org/catalogs-1.1.html#s.system) can
be used to map a URI identifying a schema location to the physical location of
a local copy of that schema document.

> **Note**
>
> Actually, a
> [`uri` element](https://www.xmlcatalogs.org/catalogs-1.1.html#s.uri) is
> supposed to be used instead of a
> [`system` element](https://www.xmlcatalogs.org/catalogs-1.1.html#s.system)
> for this purpose, according to the
> [XML catalog](https://www.xmlcatalogs.org/catalogs-1.1.html) specification.
> However, XML tools in practice usually either use `system` element or (have
> an option to) analyze both `uri` and `system` elements. The examples below
> therefore use `system`, hereby also illustrating the difference in syntax
> between `uri` and `system`. For maximum compatibility, both a `system` and
> `uri` could be included in a catalog intended for working with different
> tools.
{: .doc-callout .doc-callout--note }

**`system` element**
{: .doc-caption }

```xml
<system systemId="https://path/to/official/schema.xsd"
        uri="file:///path/to/local/copy/of/schema.xsd"/>
```

**XML instance document with a
[`xsi:schemaLocation`](https://www.w3.org/TR/xmlschema-1/#xsi_schemaLocation)
attribute**
{: .doc-caption }

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mdb:MD_Metadata xmlns:cit="https://schemas.isotc211.org/19115/-1/cit/1.3"
                 xmlns:gco="https://schemas.isotc211.org/19103/-/gco/1.2"
                 xmlns:lan="https://schemas.isotc211.org/19115/-1/lan/1.3"
                 xmlns:mcc="https://schemas.isotc211.org/19115/-1/mcc/1.3"
                 xmlns:mdb="https://schemas.isotc211.org/19115/-1/mdb/1.3"
                 xmlns:mri="https://schemas.isotc211.org/19115/-1/mri/1.3"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="https://schemas.isotc211.org/19115/-1/cit/1.3 https://schemas.isotc211.org/19115/-1/cit/1.3.0/cit.xsd
                                     https://schemas.isotc211.org/19103/-/gco/1.2 https://schemas.isotc211.org/19103/-/gco/1.2.0/gco.xsd
                                     https://schemas.isotc211.org/19115/-1/lan/1.3 https://schemas.isotc211.org/19115/-1/lan/1.3.0/lan.xsd
                                     https://schemas.isotc211.org/19115/-1/mcc/1.3 https://schemas.isotc211.org/19115/-1/mcc/1.3.0/mcc.xsd
                                     https://schemas.isotc211.org/19115/-1/mdb/1.3 https://schemas.isotc211.org/19115/-1/mdb/1.3.1/mdb.xsd
                                     https://schemas.isotc211.org/19115/-1/mri/1.3 https://schemas.isotc211.org/19115/-1/mri/1.3.0/mri.xsd
                                     http://www.w3.org/2001/XMLSchema-instance https://www.w3.org/2001/XMLSchema-instance.xsd">
    <!-- ... -->
</mdb:MD_Metadata>
```

**XML schema document declaring and importing
([`xsd:import`](https://www.w3.org/TR/xmlschema-1/#element-import)) namespaces
with a hint as to where the schema document may be found**
{: .doc-caption }

```xml
<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://www.w3.org/2001/XMLSchema"
        xmlns:cit="https://schemas.isotc211.org/19115/-1/cit/1.3"
        xmlns:gco="https://schemas.isotc211.org/19103/-/gco/1.2"
        xmlns:lan="https://schemas.isotc211.org/19115/-1/lan/1.3"
        targetNamespace="https://schemas.isotc211.org/19115/-1/lan/1.3"
        elementFormDefault="qualified"
        version="1.3.0">
    <import namespace="https://schemas.isotc211.org/19103/-/gco/1.2"
            schemaLocation="https://schemas.isotc211.org/19103/-/gco/1.2.0/gco.xsd"/>
    <import namespace="https://schemas.isotc211.org/19115/-1/cit/1.3"
            schemaLocation="https://schemas.isotc211.org/19115/-1/cit/1.3.0/cit.xsd"/>
    <!-- ... -->
</schema>
```

**XML catalog mapping schema locations**
{: .doc-caption }

```xml
<?xml version="1.0" encoding="UTF-8"?>
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
    <system systemId="https://schemas.isotc211.org/19115/-1/cit/1.3.0/cit.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/cit/1.3.0/cit.xsd"/>
    <system systemId="https://schemas.isotc211.org/19103/-/gco/1.2.0/gco.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19103/-/gco/1.2.0/gco.xsd"/>
    <system systemId="https://schemas.isotc211.org/19115/-1/lan/1.3.0/lan.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/lan/1.3.0/lan.xsd"/>
    <system systemId="https://schemas.isotc211.org/19115/-1/mcc/1.3.0/mcc.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/mcc/1.3.0/mcc.xsd"/>
    <system systemId="https://schemas.isotc211.org/19115/-1/mdb/1.3.1/mdb.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/mdb/1.3.1/mdb.xsd"/>
    <system systemId="https://schemas.isotc211.org/19115/-1/mri/1.3.0/mri.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19115/-1/mri/1.3.0/mri.xsd"/>
    <system systemId="https://www.w3.org/2001/XMLSchema-instance.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/2001/XMLSchema-instance.xsd"/>
</catalog>
```

## Commonly used XML schemas

Many ISO/TC 211 schemas reference the same core schemas. It is therefore
suggested to have at least the following entries in an XML catalog.

**XML catalog for commonly used XML schemas in the geospatial domain**
{: .doc-caption }

```xml
<?xml version="1.0" encoding="UTF-8"?>
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
    <uri name="http://www.w3.org/2001/XMLSchema"
         uri="file:///C:/XMLschemas/www.w3.org/2001/XMLSchema.xsd"/>
    <system systemId="http://www.w3.org/2001/XMLSchema.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/2001/XMLSchema.xsd"/>
    <system systemId="https://www.w3.org/2001/XMLSchema.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/2001/XMLSchema.xsd"/>

    <uri name="http://www.w3.org/XML/1998/namespace"
         uri="file:///C:/XMLschemas/www.w3.org/2009/01/xml.xsd"/>
    <system systemId="http://www.w3.org/2001/xml.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/2009/01/xml.xsd"/>
    <system systemId="https://www.w3.org/2001/xml.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/2009/01/xml.xsd"/>
    <system systemId="http://www.w3.org/2009/01/xml.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/2009/01/xml.xsd"/>
    <system systemId="https://www.w3.org/2009/01/xml.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/2009/01/xml.xsd"/>

    <uri name="http://www.w3.org/1999/xlink"
         uri="file:///C:/XMLschemas/www.w3.org/1999/xlink.xsd"/>
    <system systemId="http://www.w3.org/1999/xlink.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/1999/xlink.xsd"/>
    <system systemId="https://www.w3.org/1999/xlink.xsd"
            uri="file:///C:/XMLschemas/www.w3.org/1999/xlink.xsd"/>

    <uri name="http://www.opengis.net/gml/3.2"
         uri="file:///C:/XMLschemas/schemas.opengis.net/gml/3.2.1/gml.xsd"/>
    <system systemId="http://schemas.opengis.net/gml/3.2.1/gml.xsd"
            uri="file:///C:/XMLschemas/schemas.opengis.net/gml/3.2.1/gml.xsd"/>
    <system systemId="https://schemas.opengis.net/gml/3.2.1/gml.xsd"
            uri="file:///C:/XMLschemas/schemas.opengis.net/gml/3.2.1/gml.xsd"/>

    <uri name="http://www.isotc211.org/2005/gco"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gco/1.0/gco.xsd"/>
    <system systemId="https://schemas.isotc211.org/19139/-/gco/1.0/gco.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gco/1.0/gco.xsd"/>
    <system systemId="http://schemas.opengis.net/iso/19139/20070417/gco/gco.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gco/1.0/gco.xsd"/>

    <uri name="http://www.isotc211.org/2005/gmd"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gmd/1.0/gmd.xsd"/>
    <system systemId="https://schemas.isotc211.org/19139/-/gmd/1.0/gmd.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gmd/1.0/gmd.xsd"/>
    <system systemId="http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gmd/1.0/gmd.xsd"/>

    <uri name="http://www.isotc211.org/2005/gmx"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gmx/1.0/gmx.xsd"/>
    <system systemId="https://schemas.isotc211.org/19139/-/gmx/1.0/gmx.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gmx/1.0/gmx.xsd"/>
    <system systemId="http://schemas.opengis.net/iso/19139/20070417/gmx/gmx.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gmx/1.0/gmx.xsd"/>

    <uri name="http://www.isotc211.org/2005/gsr"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gsr/1.0/gsr.xsd"/>
    <system systemId="https://schemas.isotc211.org/19139/-/gsr/1.0/gsr.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gsr/1.0/gsr.xsd"/>
    <system systemId="http://schemas.opengis.net/iso/19139/20070417/gsr/gsr.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gsr/1.0/gsr.xsd"/>

    <uri name="http://www.isotc211.org/2005/gss"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gss/1.0/gss.xsd"/>
    <system systemId="https://schemas.isotc211.org/19139/-/gss/1.0/gss.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gss/1.0/gss.xsd"/>
    <system systemId="http://schemas.opengis.net/iso/19139/20070417/gss/gss.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gss/1.0/gss.xsd"/>

    <uri name="http://www.isotc211.org/2005/gts"
         uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gts/1.0/gts.xsd"/>
    <system systemId="https://schemas.isotc211.org/19139/-/gts/1.0/gts.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gts/1.0/gts.xsd"/>
    <system systemId="http://schemas.opengis.net/iso/19139/20070417/gts/gts.xsd"
            uri="file:///C:/XMLschemas/schemas.isotc211.org/19139/-/gts/1.0/gts.xsd"/>
</catalog>
```

## Documentation of XML tools with regards to XML catalogs

For convenience, links to documentation for common XML tools that support XML
catalogs are provided below.

* [Eclipse](https://help.eclipse.org/latest/topic/org.eclipse.wst.xmleditor.doc.user/topics/cxmlcat.html?cp=70_2_2_3)
* [Oxygen XML](https://www.oxygenxml.com/doc/ug-editor/topics/using-XML-Catalogs.html)
* [libxml (xmllint & xmlcatalog)](https://gitlab.gnome.org/GNOME/libxml2/-/wikis/Catalog-support)
* [XMLSpy](https://www.altova.com/manual/XMLSpy/spyprofessional/xsdtdandxsd_catalogs.html)

## Further reading

1. OASIS. *XML Catalogs*. Version 1.1. October 2005. Available from:
   <https://groups.oasis-open.org/higherlogic/ws/public/download/14810/xml-catalogs.pdf/latest>
2. NASA. *Understanding XML Catalog Files*. Available from:
   <https://pds.nasa.gov/datastandards/training/documents/Understanding%20XML%20Catalog%20Files.pdf>
3. WALSH, Norman. *XML Entity and URI Resolvers*. Version 1.5. 20 November
   2006. Available from:
   <https://xerces.apache.org/xml-commons/components/resolver/resolver-article.html>
4. COSTELLO, Roger L. *RE: Understanding XML catalogs: what they are, why they
   are used, and where they are used.* OASIS TC Archives. 26 July 2010.
   [Viewed 8 September 2026]. Available from:
   <https://lists-archive.oasis-open.org/archive/lists/xml-dev/months/201007/messages/77>

  </div>
</section>
