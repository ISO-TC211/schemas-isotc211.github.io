/**
 * Port of _plugins/schema_site/models.rb — the canonical-URL contract.
 * Every formula here is locked by unit tests (src/lib/schema-site/models.test.ts).
 */

export const DATA_EXTENSIONS = [
  '.xsd', '.xml', '.xsl', '.xslt', '.sch', '.json', '.zip',
  '.gml', '.svg', '.png', '.txt', '.adoc', '.ent', '.dtd',
]

export const SKIP_DIRS = ['.git', 'vendor', '_site', 'node_modules', 'tools', '.archive']

export interface ResourceCategoryConfig {
  label: string
  color: string
  iconSvg: string
}

export const RESOURCE_CATEGORIES: Record<string, ResourceCategoryConfig> = {
  transforms: {
    label: 'XSLT Transforms', color: 'orange',
    iconSvg: '<path stroke-linecap="round" stroke-linejoin="round" d="M4.098 19.902a3.75 3.75 0 005.304 0l6.401-6.402M6.75 21A3.75 3.75 0 013 17.25V4.125C3 3.504 3.504 3 4.125 3h5.25C9.996 3 10.5 3.504 10.5 4.125v4.072M6.75 21a3.75 3.75 0 003.75-3.75V8.197M6.75 21h13.125c.621 0 1.125-.504 1.125-1.125v-5.25c0-.621-.504-1.125-1.125-1.125h-4.072M10.5 8.197l2.88-2.88c.438-.439 1.15-.439 1.59 0l3.712 3.713c.44.44.44 1.152 0 1.59l-2.879 2.88M6.75 17.25h.008v.008H6.75v-.008z"/>',
  },
  schematron: {
    label: 'Schematron Rules', color: 'purple',
    iconSvg: '<path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 01-1.043 3.296 3.745 3.745 0 01-3.296 1.043A3.745 3.745 0 0112 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 01-3.296-1.043 3.745 3.745 0 01-1.043-3.296A3.745 3.745 0 013 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 011.043-3.296 3.746 3.746 0 013.296-1.043A3.746 3.746 0 0112 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 013.296 1.043 3.746 3.746 0 011.043 3.296A3.745 3.745 0 0121 12z"/>',
  },
  examples_xml: {
    label: 'XML Examples', color: 'blue',
    iconSvg: '<path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"/>',
  },
  examples_json: {
    label: 'JSON Examples', color: 'blue',
    iconSvg: '<path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"/>',
  },
  codelists: {
    label: 'Codelist Dictionaries', color: 'teal',
    iconSvg: '<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"/>',
  },
  bundles: {
    label: 'Download Packages', color: 'green',
    iconSvg: '<path stroke-linecap="round" stroke-linejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"/>',
  },
  general_codelists: {
    label: 'General Codelist Catalogues', color: 'teal',
    iconSvg: '<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"/>',
  },
}

export function urlPath(path: string): string {
  return path.replace(/^schemas\//, '')
}

export interface ModuleVersion {
  standard: string
  part: string
  moduleName: string
  version: string
  json: boolean
}

export function moduleVersions(hub: ModuleVersion): {
  hubPath: string
  browsePath: string
  partLabel: string
  nsVersion: string
  namespaceUri: string
} {
  const hubPath = hub.json
    ? `/json/${hub.standard}/${hub.part}/${hub.moduleName}/${hub.version}/`
    : `/${hub.standard}/${hub.part}/${hub.moduleName}/${hub.version}/`
  const browsePath = hub.json
    ? `/${hub.standard}/${hub.part}/${hub.moduleName}/${hub.version}/json/browse/`
    : `/${hub.standard}/${hub.part}/${hub.moduleName}/${hub.version}/browse/`
  const partLabel = hub.part === '-' ? 'Standalone' : `Part ${hub.part.replace(/-/g, '')}`
  const segments = hub.version.split('.')
  const nsVersion = `${segments[0]}.${segments[1]}`
  const namespaceUri = hub.json
    ? `https://schemas.isotc211.org/json/${hub.standard}/${hub.part}/${hub.moduleName}/${nsVersion}`
    : `https://schemas.isotc211.org/${hub.standard}/${hub.part}/${hub.moduleName}/${nsVersion}`
  return { hubPath, browsePath, partLabel, nsVersion, namespaceUri }
}

export function extractFromPath(
  path: string,
  standard?: string
): ModuleVersion | null {
  const stripped = path.replace(/^schemas\//, '')
  let m = stripped.match(/^json\/(\d{5})\/([^/]+)\/([^/]+)\/([^/]+)\/.+\.json$/)
  if (m) {
    return { standard: standard ?? m[1], part: m[2], moduleName: m[3], version: m[4], json: true }
  }
  m = stripped.match(/^(\d{5})\/([^/]+)\/([^/]+)\/([^/]+)\/.+\.xsd$/)
  if (m) {
    return { standard: standard ?? m[1], part: m[2], moduleName: m[3], version: m[4], json: false }
  }
  return null
}

export interface PackageAttrs {
  name: string
  title?: string
  description?: string
  status?: string
  standard?: string
  part?: string
  version?: string
  type?: string
  xsd_paths?: string[]
  file_paths?: string[]
  has_spa?: boolean
  browse_path?: string
  slug?: string
  resource_counts?: Record<string, number>
}

export class Package {
  name: string
  title: string
  description: string
  status: string
  standard?: string
  part: string
  version?: string
  type: string
  xsdPaths: string[]
  filePaths: string[]
  hasSpa: boolean
  browsePath?: string
  slug: string
  resourceCounts?: Record<string, number>

  constructor(attrs: PackageAttrs) {
    this.name = attrs.name
    this.title = attrs.title ?? attrs.name
    this.description = attrs.description ?? ''
    this.status = attrs.status ?? 'current'
    this.standard = attrs.standard
    this.version = attrs.version
    this.type = attrs.type ?? 'xsd'
    this.xsdPaths = attrs.xsd_paths ?? []
    this.filePaths = attrs.file_paths ?? []
    this.hasSpa = !!attrs.has_spa
    this.browsePath = attrs.browse_path
    this.slug = attrs.slug ?? attrs.name
    this.resourceCounts = attrs.resource_counts
    this.part = attrs.part ?? this.moduleVersions()[0]?.part ?? '-'
  }

  get json(): boolean {
    return this.type === 'json'
  }

  moduleVersions(): ModuleVersion[] {
    const paths = [...new Set([...this.xsdPaths, ...this.filePaths])]
    const out: ModuleVersion[] = []
    const seen = new Set<string>()
    for (const p of paths) {
      const mv = extractFromPath(p, this.standard)
      if (mv && !seen.has(moduleVersions(mv).hubPath)) {
        seen.add(moduleVersions(mv).hubPath)
        out.push(mv)
      }
    }
    return out
  }
}

export const STATUS_ORDER: Record<string, number> = { current: 0, draft: 1, historical: 2 }
export const STATUS_LABELS: Record<string, string> = {
  current: 'Current', draft: 'Draft', historical: 'Historical',
}

export function statusOrder(status?: string): number {
  return (status && STATUS_ORDER[status]) ?? 3
}

export function statusLabel(status?: string): string {
  return (status && STATUS_LABELS[status]) ?? (status ?? '')
}

export function filterResourcesForPart(
  stdResources: Record<string, Array<Record<string, unknown>>>,
  standard: string,
  part: string,
  packages: Package[]
): Record<string, Array<Record<string, unknown>>> {
  const hasOnlyJson = packages.every((p) => p.json)
  const result: Record<string, Array<Record<string, unknown>>> = {}
  for (const [cat, files] of Object.entries(stdResources)) {
    const relevant = files.filter((f) => {
      const path = String(f['path'] ?? '')
      const m = path.match(new RegExp(`^(?:json/)?${standard}/(-\\d+)/`))
      if (m) return m[1] === part && (!hasOnlyJson || cat === 'examples_json')
      return hasOnlyJson ? cat === 'examples_json' : true
    })
    if (relevant.length) result[cat] = relevant
  }
  return result
}
