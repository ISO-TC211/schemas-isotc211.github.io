import { describe, it, expect } from 'vitest'
import {
  urlPath,
  moduleVersions,
  extractFromPath,
  Package,
  statusOrder,
  filterResourcesForPart,
} from './models'

describe('urlPath', () => {
  it('strips the schemas/ prefix', () => {
    expect(urlPath('schemas/19115/-1/mdb/1.3.1/mdb.xsd')).toBe('19115/-1/mdb/1.3.1/mdb.xsd')
    expect(urlPath('19115/x.xsd')).toBe('19115/x.xsd')
  })
})

describe('extractFromPath', () => {
  it('parses XSD paths', () => {
    const mv = extractFromPath('schemas/19115/-1/mdb/1.3.1/mdb/1.3.1/mdb.xsd')
    expect(mv).toEqual({ standard: '19115', part: '-1', moduleName: 'mdb', version: '1.3.1', json: false })
  })
  it('parses JSON paths', () => {
    const mv = extractFromPath('schemas/json/19115/-3/cat/2.0/cat.json')
    expect(mv).toEqual({ standard: '19115', part: '-3', moduleName: 'cat', version: '2.0', json: true })
  })
  it('returns null for non-schema paths', () => {
    expect(extractFromPath('schemas/resources/codelists/codelists.xml')).toBeNull()
  })
})

describe('ModuleVersion URL formulas (canonical-URL contract)', () => {
  it('hubPath has literal /-/ segments', () => {
    expect(moduleVersions({ standard: '19115', part: '-1', moduleName: 'mdb', version: '1.3.1', json: false }).hubPath)
      .toBe('/19115/-1/mdb/1.3.1/')
  })
  it('json hubPath is under /json/', () => {
    expect(moduleVersions({ standard: '19115', part: '-3', moduleName: 'cat', version: '2.0', json: true }).hubPath)
      .toBe('/json/19115/-3/cat/2.0/')
  })
  it('browsePath placement differs for json', () => {
    expect(moduleVersions({ standard: '19136', part: '-', moduleName: 'gml', version: '1.0', json: false }).browsePath)
      .toBe('/19136/-/gml/1.0/browse/')
    expect(moduleVersions({ standard: '19115', part: '-3', moduleName: 'cat', version: '2.0', json: true }).browsePath)
      .toBe('/19115/-3/cat/2.0/json/browse/')
  })
  it('namespaceUri truncates to major.minor', () => {
    expect(moduleVersions({ standard: '19115', part: '-1', moduleName: 'mdb', version: '1.3.1', json: false }).namespaceUri)
      .toBe('https://schemas.isotc211.org/19115/-1/mdb/1.3')
  })
  it('partLabel handles standalone', () => {
    expect(moduleVersions({ standard: '19136', part: '-', moduleName: 'gml', version: '1.0', json: false }).partLabel).toBe('Standalone')
    expect(moduleVersions({ standard: '19115', part: '-1', moduleName: 'mdb', version: '1.3.1', json: false }).partLabel).toBe('Part 1')
  })
})

describe('Package', () => {
  it('computes part from module versions when absent', () => {
    const p = new Package({
      name: 'mdb-1.3', standard: '19115',
      xsd_paths: ['schemas/19115/-1/mdb/1.3.1/mdb/1.3.1/mdb.xsd'],
    })
    expect(p.part).toBe('-1')
  })
  it('defaults to "-" with no paths', () => {
    expect(new Package({ name: 'x' }).part).toBe('-')
  })
})

describe('statusOrder', () => {
  it('orders current < draft < historical < unknown', () => {
    expect(statusOrder('current')).toBeLessThan(statusOrder('draft'))
    expect(statusOrder('draft')).toBeLessThan(statusOrder('historical'))
    expect(statusOrder('historical')).toBeLessThan(statusOrder('weird'))
  })
})

describe('filterResourcesForPart', () => {
  const res = {
    examples_xml: [{ path: '19115/-1/mdb/examples/a.xml' }, { path: '19115/-2/x/b.xml' }],
    examples_json: [{ path: 'json/19115/-3/cat/examples/c.json' }],
    transforms: [{ path: '19115/resources/transforms/t.xsl' }],
  }
  it('keeps matching part and standard-level resources', () => {
    const out = filterResourcesForPart(res, '19115', '-1', [new Package({ name: 'mdb' })])
    expect(out['examples_xml']).toHaveLength(1)
    expect(out['transforms']).toHaveLength(1)
    expect(out['examples_json']).toBeUndefined()
  })
  it('json-only packages keep only examples_json', () => {
    const p = new Package({ name: 'cat', type: 'json' })
    const out = filterResourcesForPart(res, '19115', '-3', [p])
    expect(out['examples_json']).toHaveLength(1)
    expect(out['examples_xml']).toBeUndefined()
    expect(out['transforms']).toBeUndefined()
  })
})
