document.addEventListener('DOMContentLoaded', () => {
  loadResources()
})

const CATEGORY_META = {
  transforms:    { label: 'XSLT Transforms',        badge: 'badge--xslt',       color: 'orange' },
  schematron:    { label: 'Schematron Rules',        badge: 'badge--schematron', color: 'purple' },
  examples_xml:  { label: 'XML Examples',            badge: 'badge--examples',   color: 'blue' },
  examples_json: { label: 'JSON Examples',           badge: 'badge--json-chip',  color: 'teal' },
  codelists:     { label: 'Codelist Dictionaries',   badge: 'badge--codelists',  color: 'green' },
  bundles:       { label: 'Download Packages',        badge: 'badge--bundles',    color: 'slate' },
}

const CATEGORY_SVG = {
  transforms: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5"/></svg>',
  schematron: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z"/></svg>',
  examples_xml: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"/></svg>',
  examples_json: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"/></svg>',
  codelists: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"/></svg>',
  bundles: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"/></svg>',
}

async function loadResources() {
  const container = document.getElementById('resource-groups')
  const filterInput = document.getElementById('resource-filter')
  const countEl = document.getElementById('resource-count')
  const chipsContainer = document.getElementById('resource-type-chips')
  const standardSelect = document.getElementById('resource-standard')
  if (!container) return

  let data = {}
  try {
    const res = await fetch('/resources_index.json')
    const json = await res.json()
    data = json.standards || {}
  } catch {
    container.innerHTML = emptyState('Could not load resource index. Run <code>make all</code> to build.')
    return
  }

  // Compute category totals
  const categoryTotals = {}
  let grandTotal = 0
  for (const categories of Object.values(data)) {
    for (const [cat, files] of Object.entries(categories)) {
      categoryTotals[cat] = (categoryTotals[cat] || 0) + files.length
      grandTotal += files.length
    }
  }

  // Build type chips
  const orderedTypes = Object.keys(CATEGORY_META).filter(t => categoryTotals[t])
  let chipsHtml = `<button class="res-chip res-chip--active" data-type="">
    <span class="res-chip__label">All</span>
    <span class="res-chip__count">${grandTotal}</span>
  </button>`
  orderedTypes.forEach(type => {
    const meta = CATEGORY_META[type]
    chipsHtml += `<button class="res-chip" data-type="${type}">
      <span class="res-chip__icon">${CATEGORY_SVG[type]}</span>
      <span class="res-chip__label">${esc(meta.label)}</span>
      <span class="res-chip__count">${categoryTotals[type]}</span>
    </button>`
  })
  chipsContainer.innerHTML = chipsHtml

  // Build standard dropdown
  const standards = Object.keys(data).sort()
  standards.forEach(std => {
    const total = Object.values(data[std]).reduce((s, f) => s + f.length, 0)
    const opt = document.createElement('option')
    opt.value = std
    opt.textContent = `ISO ${std} (${total})`
    standardSelect.appendChild(opt)
  })

  let activeType = ''
  let activeStandard = ''

  // URL params
  const params = new URLSearchParams(window.location.search)
  if (params.has('type') && categoryTotals[params.get('type')]) {
    activeType = params.get('type')
  }
  if (params.has('standard') && data[params.get('standard')]) {
    activeStandard = params.get('standard')
  }

  function syncUI() {
    // Sync chips
    chipsContainer.querySelectorAll('.res-chip').forEach(btn => {
      const isActive = btn.dataset.type === activeType
      btn.classList.toggle('res-chip--active', isActive)
    })
    // Sync dropdown
    standardSelect.value = activeStandard
  }

  // Chip clicks
  chipsContainer.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-type]')
    if (!btn) return
    activeType = btn.dataset.type
    syncUI()
    render(filterInput.value, activeType, activeStandard)
  })

  // Standard dropdown
  standardSelect.addEventListener('change', () => {
    activeStandard = standardSelect.value
    render(filterInput.value, activeType, activeStandard)
  })

  // Search
  if (filterInput) {
    filterInput.addEventListener('input', () => render(filterInput.value, activeType, activeStandard))
  }

  syncUI()

  function render(query = '', typeFilter = '', standardFilter = '') {
    const q = query.toLowerCase().trim()
    let totalVisible = 0
    let html = ''

    for (const [standard, categories] of Object.entries(data)) {
      if (standardFilter && standard !== standardFilter) continue

      let groupHtml = ''
      let groupCount = 0

      for (const [category, files] of Object.entries(categories)) {
        if (typeFilter && category !== typeFilter) continue

        const filtered = q
          ? files.filter(f =>
              f.name.toLowerCase().includes(q) ||
              f.description.toLowerCase().includes(q) ||
              f.path.toLowerCase().includes(q))
          : files

        if (filtered.length === 0) continue
        groupCount += filtered.length

        const meta = CATEGORY_META[category] || { label: category, badge: '', color: 'slate' }
        const svg = CATEGORY_SVG[category] || ''
        groupHtml += `
          <div class="res-category">
            <div class="res-category__header">
              <span class="res-category__icon res-category__icon--${meta.color}">${svg}</span>
              <h3 class="res-category__title">${esc(meta.label)}</h3>
              <span class="badge ${meta.badge}">${filtered.length}</span>
            </div>
            <div class="res-list">
              ${filtered.map(f => `
                <a href="/${esc(f.path)}" class="res-item">
                  <span class="res-item__dot res-item__dot--${meta.color}"></span>
                  <span class="res-item__name">${esc(f.name)}</span>
                  <span class="res-item__desc">${esc(f.description)}</span>
                </a>
              `).join('')}
            </div>
          </div>`
      }

      if (groupCount === 0) continue
      totalVisible += groupCount

      html += `
        <div class="res-group">
          <div class="res-group__header">
            <h2 class="res-group__title">ISO ${esc(standard)}</h2>
            <span class="res-group__count">${groupCount} resource${groupCount > 1 ? 's' : ''}</span>
          </div>
          ${groupHtml}
        </div>`
    }

    if (totalVisible === 0) {
      html = emptyState('No resources match your filters.')
    }

    container.innerHTML = html
    if (countEl) countEl.textContent = `${totalVisible}`
  }

  render(filterInput ? filterInput.value : '', activeType, activeStandard)
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
