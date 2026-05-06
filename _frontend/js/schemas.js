document.addEventListener('DOMContentLoaded', () => {
  loadSchemas()
})

async function loadSchemas() {
  const container = document.getElementById('schema-groups')
  const filterInput = document.getElementById('schema-filter')
  const countEl = document.getElementById('schema-count')
  if (!container) return

  let schemas = []
  let resourceMap = {}
  try {
    const [schemaRes, resourceRes] = await Promise.all([
      fetch('/schemas_index.json'),
      fetch('/resources_index.json'),
    ])
    schemas = await schemaRes.json()
    const resourceData = await resourceRes.json()
    if (resourceData.standards) {
      resourceMap = resourceData.standards
    }
  } catch {
    container.innerHTML = emptyState('Could not load schema index. Run <code>make all</code> to build.')
    return
  }

  const grouped = groupByStandardPart(schemas)

  function render(query = '') {
    const q = query.toLowerCase().trim()
    let html = ''
    let visibleCount = 0

    for (const [key, data] of grouped) {
      if (q && !key.toLowerCase().includes(q) &&
          !data.title.toLowerCase().includes(q) &&
          !data.standard.includes(q)) continue

      visibleCount++

      const resInfo = buildResourceChips(data.standard, resourceMap[data.standard])

      html += `
        <a href="/${esc(data.url)}/" class="std-card animate-fade-in-up" style="animation-delay: ${visibleCount * 30}ms">
          <div class="std-card__number">ISO ${esc(data.label)}</div>
          <div class="std-card__body">
            <div class="std-card__meta">
              <span class="std-card__packages">${data.packages.length} package${data.packages.length !== 1 ? 's' : ''}</span>
            </div>
            <div class="std-card__types">
              ${data.types.size > 0 ? Array.from(data.types).sort().map(t =>
                t === 'json' ? '<span class="badge badge--json">JSON</span>' : '<span class="badge badge--current">XSD</span>'
              ).join(' ') : ''}
              ${resInfo}
            </div>
          </div>
          <svg class="std-card__arrow" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5"/>
          </svg>
        </a>`
    }

    if (visibleCount === 0) {
      html = emptyState('No standards match your search.')
    }

    container.innerHTML = html
    if (countEl) countEl.textContent = `${visibleCount} standard${visibleCount !== 1 ? 's' : ''}`
  }

  if (filterInput) {
    filterInput.addEventListener('input', (e) => render(e.target.value))
  }

  render()
}

function buildResourceChips(standard, resources) {
  if (!resources) return ''
  const chips = []
  const labels = {
    transforms: { label: 'XSLT', badge: 'badge--xslt' },
    schematron: { label: 'Schematron', badge: 'badge--schematron' },
    examples_xml: { label: 'XML Examples', badge: 'badge--examples' },
    examples_json: { label: 'JSON Examples', badge: 'badge--examples' },
    codelists: { label: 'Codelists', badge: 'badge--codelists' },
    bundles: { label: 'Bundles', badge: 'badge--bundles' },
  }
  for (const [cat, files] of Object.entries(resources)) {
    if (!files || files.length === 0) continue
    const info = labels[cat]
    if (!info) continue
    chips.push(`<span class="badge ${info.badge}">${files.length} ${info.label}</span>`)
  }
  return chips.join('')
}

function groupByStandardPart(schemas) {
  const groups = new Map()

  for (const s of schemas) {
    const standard = s.standard || 'unknown'
    const part = s.part || '-'
    const key = `${standard}/${part}`

    if (!groups.has(key)) {
      const partNum = part === '-' ? '' : part.replace('-', '')
      const label = partNum ? `${standard}-${partNum}` : standard
      const url = part === '-' ? standard : `${standard}/${part}`

      groups.set(key, {
        standard,
        part,
        label,
        url,
        title: `ISO ${label}`,
        packages: [],
        types: new Set(),
      })
    }

    const g = groups.get(key)
    g.packages.push(s)
    g.types.add(s.type || 'xsd')
  }

  // Sort: standalone first, then by standard number, then by part
  const sorted = new Map(
    [...groups.entries()].sort(([a], [b]) => {
      const [sa, pa] = a.split('/')
      const [sb, pb] = b.split('/')
      const cmp = sa.localeCompare(sb, undefined, { numeric: true })
      return cmp !== 0 ? cmp : (pa === '-' ? -1 : pb === '-' ? 1 : pa.localeCompare(pb, undefined, { numeric: true }))
    })
  )

  return sorted
}

function emptyState(msg) {
  return `<div class="empty-state">
    <div class="empty-state__icon">&#128269;</div>
    <p class="empty-state__text">${msg}</p>
  </div>`
}

function esc(str) {
  const d = document.createElement('div')
  d.textContent = str
  return d.innerHTML
}
