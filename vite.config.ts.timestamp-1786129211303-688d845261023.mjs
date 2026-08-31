// vite.config.ts
import { defineConfig } from "file:///C:/Users/91891/Downloads/Telegram%20Desktop/SarjanaHRMS-main%20(6)/SarjanaHRMS-main%20(4)/SarjanaHRMS-main/node_modules/vite/dist/node/index.js";
import react from "file:///C:/Users/91891/Downloads/Telegram%20Desktop/SarjanaHRMS-main%20(6)/SarjanaHRMS-main%20(4)/SarjanaHRMS-main/node_modules/@vitejs/plugin-react/dist/index.js";
var vite_config_default = defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": "/src"
    }
  },
  server: {
    port: 8e3,
    strictPort: true,
    host: true,
    // Allow external connections
    open: true,
    cors: true,
    // Allow ngrok and localhost
    allowedHosts: [
      "localhost",
      "127.0.0.1",
      "unlaughing-junie-uncreative.ngrok-free.dev"
    ],
    proxy: {
      "/api": {
        target: "http://localhost:3001",
        changeOrigin: true
      }
    }
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFw5MTg5MVxcXFxEb3dubG9hZHNcXFxcVGVsZWdyYW0gRGVza3RvcFxcXFxTYXJqYW5hSFJNUy1tYWluICg2KVxcXFxTYXJqYW5hSFJNUy1tYWluICg0KVxcXFxTYXJqYW5hSFJNUy1tYWluXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ZpbGVuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFw5MTg5MVxcXFxEb3dubG9hZHNcXFxcVGVsZWdyYW0gRGVza3RvcFxcXFxTYXJqYW5hSFJNUy1tYWluICg2KVxcXFxTYXJqYW5hSFJNUy1tYWluICg0KVxcXFxTYXJqYW5hSFJNUy1tYWluXFxcXHZpdGUuY29uZmlnLnRzXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ltcG9ydF9tZXRhX3VybCA9IFwiZmlsZTovLy9DOi9Vc2Vycy85MTg5MS9Eb3dubG9hZHMvVGVsZWdyYW0lMjBEZXNrdG9wL1NhcmphbmFIUk1TLW1haW4lMjAoNikvU2FyamFuYUhSTVMtbWFpbiUyMCg0KS9TYXJqYW5hSFJNUy1tYWluL3ZpdGUuY29uZmlnLnRzXCI7aW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSAndml0ZSc7XHJcbmltcG9ydCByZWFjdCBmcm9tICdAdml0ZWpzL3BsdWdpbi1yZWFjdCc7XHJcblxyXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xyXG4gIHBsdWdpbnM6IFtyZWFjdCgpXSxcclxuICByZXNvbHZlOiB7XHJcbiAgICBhbGlhczoge1xyXG4gICAgICAnQCc6ICcvc3JjJyxcclxuICAgIH0sXHJcbiAgfSxcclxuICBzZXJ2ZXI6IHtcclxuICAgIHBvcnQ6IDgwMDAsXHJcbiAgICBzdHJpY3RQb3J0OiB0cnVlLFxyXG4gICAgaG9zdDogdHJ1ZSwgLy8gQWxsb3cgZXh0ZXJuYWwgY29ubmVjdGlvbnNcclxuICAgIG9wZW46IHRydWUsXHJcbiAgICBjb3JzOiB0cnVlLFxyXG4gICAgLy8gQWxsb3cgbmdyb2sgYW5kIGxvY2FsaG9zdFxyXG4gICAgYWxsb3dlZEhvc3RzOiBbXHJcbiAgICAgICdsb2NhbGhvc3QnLFxyXG4gICAgICAnMTI3LjAuMC4xJyxcclxuICAgICAgJ3VubGF1Z2hpbmctanVuaWUtdW5jcmVhdGl2ZS5uZ3Jvay1mcmVlLmRldidcclxuICAgIF0sXHJcbiAgICBwcm94eToge1xyXG4gICAgICAnL2FwaSc6IHtcclxuICAgICAgICB0YXJnZXQ6ICdodHRwOi8vbG9jYWxob3N0OjMwMDEnLFxyXG4gICAgICAgIGNoYW5nZU9yaWdpbjogdHJ1ZSxcclxuICAgICAgfSxcclxuICAgIH0sXHJcbiAgfSxcclxufSk7XHJcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBb2YsU0FBUyxvQkFBb0I7QUFDamhCLE9BQU8sV0FBVztBQUVsQixJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixTQUFTLENBQUMsTUFBTSxDQUFDO0FBQUEsRUFDakIsU0FBUztBQUFBLElBQ1AsT0FBTztBQUFBLE1BQ0wsS0FBSztBQUFBLElBQ1A7QUFBQSxFQUNGO0FBQUEsRUFDQSxRQUFRO0FBQUEsSUFDTixNQUFNO0FBQUEsSUFDTixZQUFZO0FBQUEsSUFDWixNQUFNO0FBQUE7QUFBQSxJQUNOLE1BQU07QUFBQSxJQUNOLE1BQU07QUFBQTtBQUFBLElBRU4sY0FBYztBQUFBLE1BQ1o7QUFBQSxNQUNBO0FBQUEsTUFDQTtBQUFBLElBQ0Y7QUFBQSxJQUNBLE9BQU87QUFBQSxNQUNMLFFBQVE7QUFBQSxRQUNOLFFBQVE7QUFBQSxRQUNSLGNBQWM7QUFBQSxNQUNoQjtBQUFBLElBQ0Y7QUFBQSxFQUNGO0FBQ0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
