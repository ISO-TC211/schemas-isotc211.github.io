document.addEventListener('DOMContentLoaded', () => {
  loadSchemas()
})

async function loadSchemas() {
  const container = document.getElementById('schema-groups')
  const filterInput = document.getElementById('schema-filter')
  const countEl = document.getElementById('schema-count')
  if (!container) return

  let schemas = []
  try {
    const res = await fetch('/schemas_index.json')
    schemas = await res.json()
  } catch {
    container.innerHTML = emptyState('Could not load schema index. Run <code>make all</code> to build.')
    return
  }

  const grouped = groupByStandard(schemas)

  function render(query = '') {
    const q = query.toLowerCase().trim()
    let totalVisible = 0
    let html = ''

    for (const [standard, pkgs] of grouped) {
      const filtered = q
        ? pkgs.filter(p =>
            p.name.toLowerCase().includes(q) ||
            p.standard.includes(q) ||
            p.description.toLowerCase().includes(q) ||
            p.version.includes(q))
        : pkgs

      if (filtered.length === 0) continue
      totalVisible += filtered.length

      // Count parts: extract unique part numbers from xsd_paths
      const parts = new Set()
      for (const p of pkgs) {
        for (const path of (p.xsd_paths || p.file_paths || [])) {
          const m = path.match(/schemas\/\d+\/([^/]+)\//)
          if (m) parts.add(m[1])
        }
      }
      const partsLabel = parts.size > 0
        ? Array.from(parts).sort().map(p => p === '-' ? 'Standalone' : `Part ${p.replace('-', '')}`).join(', ')
        : ''

      html += `
        <div class="std-group">
          <a href="/${esc(standard)}/" class="std-group__header">
            <h3 class="std-group__title">ISO ${esc(standard)}</h3>
            ${partsLabel ? `<span class="std-group__parts">${esc(partsLabel)}</span>` : ''}
            <span class="std-group__count">${filtered.length} package${filtered.length > 1 ? 's' : ''}</span>
            <svg class="std-group__arrow" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5"/>
            </svg>
          </a>
          <div class="schema-cards">
            ${filtered.map((s, i) => renderCard(s, i)).join('')}
          </div>
        </div>`
    }

    if (totalVisible === 0) {
      html = emptyState('No schemas match your search.')
    }

    container.innerHTML = html
    if (countEl) countEl.textContent = `${totalVisible} package${totalVisible !== 1 ? 's' : ''}`
  }

  if (filterInput) {
    filterInput.addEventListener('input', (e) => render(e.target.value))
  }

  render()
}

function groupByStandard(schemas) {
  const groups = {}
  for (const s of schemas) {
    const key = s.standard || 'unknown'
    if (!groups[key]) groups[key] = []
    groups[key].push(s)
  }
  // Sort current before historical within each group
  for (const key of Object.keys(groups)) {
    groups[key].sort((a, b) => {
      const statusOrder = { current: 0, draft: 1, historical: 2 }
      const sa = statusOrder[a.status] ?? 3
      const sb = statusOrder[b.status] ?? 3
      if (sa !== sb) return sa - sb
      return b.version.localeCompare(a.version, undefined, { numeric: true })
    })
  }
  return Object.entries(groups).sort(([a], [b]) =>
    a.localeCompare(b, undefined, { numeric: true })
  )
}

function renderCard(schema, index) {
  const badgeClass = `badge--${schema.status || 'historical'}`
  const badgeLabel = { current: 'Current', draft: 'Draft', historical: 'Historical' }[schema.status] || schema.status
  const isJson = schema.type === 'json'
  const fileExt = isJson ? 'JSON' : 'XSD'
  const fileKey = isJson ? 'file_paths' : 'xsd_paths'
  const files = schema[fileKey] || []
  const typeBadge = isJson
    ? '<span class="badge badge--json">JSON</span>'
    : ''

  return `
    <div class="schema-card animate-fade-in-up" style="animation-delay: ${index * 40}ms"
         ${schema.has_spa ? `onclick="window.location='/${esc(schema.browser_path)}'"` : ''}>
      <div class="schema-card__top">
        <span class="schema-card__name">${esc(schema.name)}</span>
        <div class="schema-card__badges">
          ${typeBadge}
          <span class="badge ${badgeClass}">${badgeLabel}</span>
        </div>
      </div>
      <p class="schema-card__desc">${esc(schema.description)}</p>
      <div class="schema-card__version">Version <code>${esc(schema.version)}</code></div>
      <div class="schema-card__actions">
        ${schema.has_spa ? `
          <a href="/${esc(schema.browser_path)}" class="schema-card__browse" onclick="event.stopPropagation()">
            Browse schema
            <svg fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/>
            </svg>
          </a>` : ''}
        ${files.length > 0 ? `
          <a href="/${esc(files[0])}" class="schema-card__download" onclick="event.stopPropagation()" title="Download ${fileExt}">
            <svg fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3"/>
            </svg>
            ${fileExt}
          </a>` : ''}
      </div>
    </div>`
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
