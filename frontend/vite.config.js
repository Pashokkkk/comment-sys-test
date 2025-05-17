import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],

  // 👉 Статичні файли шукатимуться з кореня
  base: '/',

  // 👉 Вивід у /frontend/dist (як очікує Django)
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    manifest: true
  },

  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
      jquery: 'jquery/dist/jquery.js',
    },
  },

  server: {
    proxy: {
      '/media': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  },

  define: {
    global: {},
  },

  optimizeDeps: {
    include: ['jquery'],
  },
})
