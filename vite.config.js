import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './'),
      '@/components': path.resolve(__dirname, './components'),
      '@/Pages': path.resolve(__dirname, './Pages'),
      '@/Entities': path.resolve(__dirname, './Entities'),
      '@/utils': path.resolve(__dirname, './utils'),
      '@/data': path.resolve(__dirname, './data'),
    },
  },
  server: {
    port: 3000,
    host: true, // Allow external connections
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          motion: ['framer-motion'],
          icons: ['lucide-react'],
        },
      },
    },
  },
  define: {
    global: 'globalThis',
  },
})
