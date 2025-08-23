
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // Configure Vite's dev server to proxy API calls.  This avoids CORS issues
  // by forwarding requests starting with `/api` to the remote backend.  When
  // deploying the app behind the same domain as the API, you can remove
  // this proxy configuration and set `API_BASE` accordingly.
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'https://parttec.onrender.com',
        changeOrigin: true,
        secure: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
})
