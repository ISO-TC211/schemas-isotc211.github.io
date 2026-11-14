<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'

interface ResourceFile {
  name: string
  path: string
  description?: string
}
type Standards = Record<string, Record<string, ResourceFile[]>>

const props = defineProps<{ standards: Standards }>()

const CATEGORY_META: Record<string, { label: string; badge: string; color: string }> = {
  transforms: { label: 'XSLT Transforms', badge: 'badge--xslt', color: 'orange' },
  schematron: { label: 'Schematron Rules', badge: 'badge--schematron', color: 'purple' },
  examples_xml: { label: 'XML Examples', badge: 'badge--examples', color: 'blue' },
  examples_json: { label: 'JSON Examples', badge: 'badge--json-chip', color: 'teal' },
  codelists: { label: 'Codelist Dictionaries', badge: 'badge--codelists', color: 'green' },
  bundles: { label: 'Download Packages', badge: 'badge--bundles', color: 'slate' },
}

const CATEGORY_SVG: Record<string, string> = {
  transforms:
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5"/></svg>',
  schematron:
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z"/></svg>',
  examples_xml:
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"/></svg>',
  examples_json:
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"/></svg>',
  codelists:
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"/></svg>',
  bundles:
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"/></svg>',
}

const query = ref('')
const activeType = ref('')
const activeStandard = ref('')

const categoryTotals = computed(() => {
  const totals: Record<string, number> = {}
  let grand = 0
  for (const categories of Object.values(props.standards)) {
    for (const [cat, files] of Object.entries(categories)) {
      totals[cat] = (totals[cat] || 0) + files.length
      grand += files.length
    }
  }
  return { totals, grand }
})

const orderedTypes = computed(() =>
  Object.keys(CATEGORY_META).filter((t) => categoryTotals.value.totals[t])
)
const standardList = computed(() =>
  Object.keys(props.standards)
    .sort()
    .map((std) => ({
      std,
      total: Object.values(props.standards[std]).reduce((s, f) => s + f.length, 0),
    }))
)

onMounted(() => {
  const params = new URLSearchParams(window.location.search)
  if (params.has('type') && categoryTotals.value.totals[params.get('type')!]) {
    activeType.value = params.get('type')!
  }
  if (params.has('standard') && props.standards[params.get('standard')!]) {
    activeStandard.value = params.get('standard')!
  }
})

function setType(t: string) {
  activeType.value = t
  history.replaceState(null, '', t ? `?type=${t}${activeStandard.value ? `&standard=${activeStandard.value}` : ''}` : activeStandard.value ? `?standard=${activeStandard.value}` : '/')
}
function setStandard(s: string) {
  activeStandard.value = s
  const typePart = activeType.value ? `?type=${activeType.value}` : ''
  history.replaceState(null, '', s ? `${typePart ? typePart + '&' : '?'}standard=${s}` : typePart || '/')
}

const esc = (s: unknown) =>
  String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

const groups = computed(() => {
  const q = query.value.toLowerCase().trim()
  const out: Array<{ standard: string; count: number; categories: Array<{ category: string; meta: { label: string; badge: string; color: string }; svg: string; files: ResourceFile[] }> }> = []
  let totalVisible = 0
  for (const [standard, categories] of Object.entries(props.standards)) {
    if (activeStandard.value && standard !== activeStandard.value) continue
    const cats: typeof out[number]['categories'] = []
    let groupCount = 0
    for (const [category, files] of Object.entries(categories)) {
      if (activeType.value && category !== activeType.value) continue
      const filtered = q
        ? files.filter(
            (f) =>
              f.name.toLowerCase().includes(q) ||
              (f.description ?? '').toLowerCase().includes(q) ||
              f.path.toLowerCase().includes(q)
          )
        : files
      if (filtered.length === 0) continue
      groupCount += filtered.length
      cats.push({
        category,
        meta: CATEGORY_META[category] ?? { label: category, badge: '', color: 'slate' },
        svg: CATEGORY_SVG[category] ?? '',
        files: filtered,
      })
    }
    if (groupCount === 0) continue
    totalVisible += groupCount
    out.push({ standard, count: groupCount, categories: cats })
  }
  return { out, totalVisible }
})
</script>

<template>
  <div>
    <div class="res-filter">
      <div class="res-filter__bar">
        <div class="res-filter__search">
          <svg class="res-filter__search-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z"/></svg>
          <input
            v-model="query"
            type="text"
            class="res-filter__input"
            placeholder="Search resources..."
            autocomplete="off"
          />
        </div>
        <div class="res-filter__actions">
          <select v-model="activeStandard" class="res-filter__select" @change="setStandard(activeStandard)">
            <option value="">All standards</option>
            <option v-for="s in standardList" :key="s.std" :value="s.std">ISO {{ s.std }} ({{ s.total }})</option>
          </select>
          <span class="res-filter__count">{{ groups.totalVisible }}</span>
        </div>
      </div>

      <div class="res-chips">
        <button class="res-chip" :class="{ 'res-chip--active': !activeType }" @click="setType('')">
          <span class="res-chip__label">All</span>
          <span class="res-chip__count">{{ categoryTotals.grand }}</span>
        </button>
        <button
          v-for="t in orderedTypes"
          :key="t"
          class="res-chip"
          :class="{ 'res-chip--active': activeType === t }"
          @click="setType(t)"
        >
          <span class="res-chip__icon" v-html="CATEGORY_SVG[t]" />
          <span class="res-chip__label">{{ CATEGORY_META[t].label }}</span>
          <span class="res-chip__count">{{ categoryTotals.totals[t] }}</span>
        </button>
      </div>
    </div>

    <div>
      <div v-for="g in groups.out" :key="g.standard" class="res-group">
        <div class="res-group__header">
          <h2 class="res-group__title">ISO {{ g.standard }}</h2>
          <span class="res-group__count">{{ g.count }} resource{{ g.count > 1 ? 's' : '' }}</span>
        </div>
        <div v-for="c in g.categories" :key="c.category" class="res-category">
          <div class="res-category__header">
            <span class="res-category__icon" :class="`res-category__icon--${c.meta.color}`" v-html="c.svg" />
            <h3 class="res-category__title">{{ c.meta.label }}</h3>
            <span class="badge" :class="c.meta.badge">{{ c.files.length }}</span>
          </div>
          <div class="res-list">
            <a v-for="f in c.files" :key="f.path" :href="`/${esc(f.path)}`" class="res-item">
              <span class="res-item__dot" :class="`res-item__dot--${c.meta.color}`" />
              <span class="res-item__name">{{ f.name }}</span>
              <span class="res-item__desc">{{ f.description }}</span>
            </a>
          </div>
        </div>
      </div>
      <div v-if="groups.totalVisible === 0" class="empty-state">
        <div class="empty-state__icon">🔍</div>
        <p class="empty-state__text">No resources match your filters.</p>
      </div>
    </div>
  </div>
</template>
