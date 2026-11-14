<script setup lang="ts">
import { computed, ref } from 'vue'

interface Pkg {
  name: string
  title: string
  standard?: string
  part?: string
  type?: string
  resource_counts?: Record<string, number>
}

const props = defineProps<{ schemas: Pkg[] }>()

const filter = ref('')

const CHIP_LABELS: Record<string, { label: string; badge: string }> = {
  transforms: { label: 'XSL', badge: 'badge--xslt' },
  schematron: { label: 'SCH', badge: 'badge--schematron' },
  examples_xml: { label: 'XML', badge: 'badge--examples' },
  examples_json: { label: 'JSON', badge: 'badge--examples' },
  codelists: { label: 'CL', badge: 'badge--codelists' },
  bundles: { label: 'ZIP', badge: 'badge--bundles' },
}

interface Group {
  key: string
  standard: string
  part: string
  label: string
  url: string
  title: string
  packages: Pkg[]
  types: string[]
}

const groups = computed<Group[]>(() => {
  const map = new Map<string, Group>()
  for (const s of props.schemas) {
    const standard = s.standard || 'unknown'
    const part = s.part || '-'
    const key = `${standard}/${part}`
    if (!map.has(key)) {
      const partNum = part === '-' ? '' : part.replace('-', '')
      const label = partNum ? `${standard}-${partNum}` : standard
      map.set(key, {
        key,
        standard,
        part,
        label,
        url: part === '-' ? standard : `${standard}/${part}`,
        title: `ISO ${label}`,
        packages: [],
        types: [],
      })
    }
    const g = map.get(key)!
    g.packages.push(s)
    if (!g.types.includes(s.type || 'xsd')) g.types.push(s.type || 'xsd')
  }
  return [...map.values()].sort(([a], [b]) => 0 - 0).sort((a, b) => {
    const [sa, pa] = a.key.split('/')
    const [sb, pb] = b.key.split('/')
    const cmp = sa.localeCompare(sb, undefined, { numeric: true })
    return cmp !== 0 ? cmp : pa === '-' ? -1 : pb === '-' ? 1 : pa.localeCompare(pb, undefined, { numeric: true })
  })
})

const resourceChips = (pkgList: Pkg[]) => {
  const deduped: Record<string, number> = {}
  for (const pkg of pkgList) {
    for (const [cat, count] of Object.entries(pkg.resource_counts ?? {})) {
      deduped[cat] = Math.max(deduped[cat] || 0, count)
    }
  }
  const chips: string[] = []
  for (const [cat, count] of Object.entries(deduped)) {
    const info = CHIP_LABELS[cat]
    if (!info || count === 0) continue
    chips.push(`<span class="badge ${info.badge}">${count} ${info.label}</span>`)
  }
  return chips.join('')
}

const filtered = computed(() => {
  const q = filter.value.toLowerCase().trim()
  if (!q) return groups.value
  return groups.value.filter(
    (g) => g.key.toLowerCase().includes(q) || g.title.toLowerCase().includes(q) || g.standard.includes(q)
  )
})

const esc = (s: string) =>
  s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
</script>

<template>
  <div>
    <template v-for="(g, gi) in filtered" :key="g.key">
      <a
        :href="`/${g.url}/`"
        class="std-card animate-fade-in-up"
        :style="`animation-delay: ${(gi + 1) * 30}ms`"
      >
        <div class="std-card__number">ISO {{ g.label }}</div>
        <div class="std-card__body">
          <div class="std-card__meta">
            <span class="std-card__packages">{{ g.packages.length }} package{{ g.packages.length !== 1 ? 's' : '' }}</span>
          </div>
          <div class="std-card__types">
            <template v-for="t in [...g.types].sort()" :key="t">
              <span v-if="t === 'json'" class="badge badge--json">JSON</span>
              <span v-else class="badge badge--current">XSD</span>
            </template>
            <span v-if="resourceChips(g.packages)" v-html="resourceChips(g.packages)" />
          </div>
        </div>
        <svg class="std-card__arrow" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
        </svg>
      </a>
    </template>
    <div v-if="filtered.length === 0" class="empty-state">
      <div class="empty-state__icon">🔍</div>
      <p class="empty-state__text">No standards match your search.</p>
    </div>
  </div>
</template>
