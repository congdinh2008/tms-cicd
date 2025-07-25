/// <reference types="vitest" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 2025,
  },
  preview: {
    host: '0.0.0.0',
    port: 2025,
  },
  plugins: [react()],
})
