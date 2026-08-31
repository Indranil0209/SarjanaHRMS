import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': '/src',
    },
  },
  server: {
    port: 8000,
    strictPort: true,
    host: true, // Allow external connections
    open: true,
    cors: true,
    // Allow ngrok and localhost
    allowedHosts: [
      'localhost',
      '127.0.0.1',
      'unlaughing-junie-uncreative.ngrok-free.dev'
    ],
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
});
