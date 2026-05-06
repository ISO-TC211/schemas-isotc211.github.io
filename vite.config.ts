import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { execSync } from 'child_process'
import path from 'path'

function themeFrontendPath(subdir: string): string {
  try {
    const gemDir = execSync('bundle show jekyll-theme-isotc211', { encoding: 'utf-8' }).trim()
    return path.resolve(gemDir, '_frontend', subdir) + '/'
  } catch {
    return path.resolve(__dirname, '..', 'jekyll-theme-isotc211', '_frontend', subdir) + '/'
  }
}

export default defineConfig(({ mode }) => ({
  plugins: [
    RubyPlugin(),
  ],
  resolve: {
    alias: {
      'theme-css/': themeFrontendPath('css'),
      'theme-js/': themeFrontendPath('js'),
    },
  },
  css: {
    devSourcemap: true,
  },
  build: {
    sourcemap: mode === 'development',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: mode === 'production',
      },
    },
  },
}))
