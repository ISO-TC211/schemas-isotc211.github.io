import { defineConfig } from 'astro/config'
import vue from '@astrojs/vue'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  site: 'https://schemas.isotc211.org',
  trailingSlash: 'always',
  build: { format: 'directory' },
  integrations: [vue()],
  vite: {
    resolve: { alias: { '@': new URL('./src', import.meta.url).pathname } },
    plugins: [tailwindcss()],
  },
})
