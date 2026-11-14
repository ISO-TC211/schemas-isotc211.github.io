#!/usr/bin/env node
// Replaces _plugins/redirect_generator.rb + jekyll-redirect-from:
// - data-file extensions: copy the real target file to the legacy path
// - HTML/directory paths: meta-refresh + canonical page
import { copyFileSync, existsSync, mkdirSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { parse } from 'yaml'

const DATA_EXTENSIONS = new Set([
  '.xsd', '.xml', '.xsl', '.xslt', '.sch', '.json', '.zip',
  '.gml', '.svg', '.png', '.txt', '.adoc', '.ent', '.dtd',
])

const dist = join(process.cwd(), 'dist')
const listPath = join(process.cwd(), '_data', 'redirects.yml')
const redirects = parse(readFileSync(listPath, 'utf8'))
// jekyll-redirect-from page-level entries (front matter in the legacy site)
redirects.push({ from: '/transforms/', to: '/resources/' })

let ok = 0
let fail = 0
for (const r of redirects) {
  const from = r.from ?? r['from']
  const to = r.to ?? r['to']
  const ext = from.slice(from.lastIndexOf('.'))
  const isData = !from.endsWith('/') && DATA_EXTENSIONS.has(ext)
  try {
    if (isData) {
      const targetPath = join(dist, to.endsWith('/') ? join(to, 'index.html') : to)
      if (!existsSync(targetPath)) {
        console.warn(`redirect SKIP (target missing upstream) ${from} -> ${to}`)
        continue
      }
      const fromPath = join(dist, from)
      mkdirSync(dirname(fromPath), { recursive: true })
      copyFileSync(targetPath, fromPath)
      console.log(`redirect[data] ${from}`)
    } else {
      const fromDir = from.endsWith('/') ? from : `${from}/`
      const pageDir = join(dist, fromDir)
      mkdirSync(pageDir, { recursive: true })
      const html = `<!DOCTYPE html>\n<html lang="en"><head><meta charset="utf-8">\n<link rel="canonical" href="${to}"/>\n<meta http-equiv="refresh" content="0; url=${to}"/>\n</head><body><script>window.location.href='${to}'</script>\n<p>Redirecting to <a href="${to}">${to}</a>…</p></body></html>\n`
      writeFileSync(join(pageDir, 'index.html'), html)
      console.log(`redirect[page] ${from} -> ${to}`)
    }
    ok++
  } catch (e) {
    console.error(`redirect FAILED ${from}: ${e}`)
    fail++
  }
}
console.log(`postbuild: ${ok} redirects written, ${fail} failures`)

// News posts: Jekyll emitted .html FILES at /update/{yyyy}/{mm}/{dd}/{slug}.html;
// move Astro's directory output to those exact legacy file paths.
const updateRoot = join(dist, 'update')
if (existsSync(updateRoot)) {
  let moved = 0
  function walkUpdate(dir) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, entry.name)
      if (entry.isDirectory()) {
        walkUpdate(full)
        if (existsSync(join(full, 'index.html')) && readdirSync(full).length === 1) {
          const target = `${full}.html`
          mkdirSync(dirname(target), { recursive: true })
          renameSync(join(full, 'index.html'), target)
          rmSync(full, { recursive: true })
          moved++
          console.log(`postbuild: ${target.replace(dist, '')}`)
        }
      }
    }
  }
  walkUpdate(updateRoot)
  console.log(`postbuild: moved ${moved} news page(s) to legacy .html paths`)
}

process.exit(fail ? 1 : 0)
