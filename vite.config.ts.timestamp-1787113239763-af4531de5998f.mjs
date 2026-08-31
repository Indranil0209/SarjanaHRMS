// vite.config.ts
import { defineConfig } from "file:///C:/Users/91891/Downloads/Telegram%20Desktop/SarjanaHRMS-main%20(2)/SarjanaHRMS-main%20(6)/SarjanaHRMS-main%20(6)/SarjanaHRMS-main/node_modules/vite/dist/node/index.js";
import react from "file:///C:/Users/91891/Downloads/Telegram%20Desktop/SarjanaHRMS-main%20(2)/SarjanaHRMS-main%20(6)/SarjanaHRMS-main%20(6)/SarjanaHRMS-main/node_modules/@vitejs/plugin-react/dist/index.js";
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
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFw5MTg5MVxcXFxEb3dubG9hZHNcXFxcVGVsZWdyYW0gRGVza3RvcFxcXFxTYXJqYW5hSFJNUy1tYWluICgyKVxcXFxTYXJqYW5hSFJNUy1tYWluICg2KVxcXFxTYXJqYW5hSFJNUy1tYWluICg2KVxcXFxTYXJqYW5hSFJNUy1tYWluXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ZpbGVuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFw5MTg5MVxcXFxEb3dubG9hZHNcXFxcVGVsZWdyYW0gRGVza3RvcFxcXFxTYXJqYW5hSFJNUy1tYWluICgyKVxcXFxTYXJqYW5hSFJNUy1tYWluICg2KVxcXFxTYXJqYW5hSFJNUy1tYWluICg2KVxcXFxTYXJqYW5hSFJNUy1tYWluXFxcXHZpdGUuY29uZmlnLnRzXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ltcG9ydF9tZXRhX3VybCA9IFwiZmlsZTovLy9DOi9Vc2Vycy85MTg5MS9Eb3dubG9hZHMvVGVsZWdyYW0lMjBEZXNrdG9wL1NhcmphbmFIUk1TLW1haW4lMjAoMikvU2FyamFuYUhSTVMtbWFpbiUyMCg2KS9TYXJqYW5hSFJNUy1tYWluJTIwKDYpL1NhcmphbmFIUk1TLW1haW4vdml0ZS5jb25maWcudHNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tICd2aXRlJztcclxuaW1wb3J0IHJlYWN0IGZyb20gJ0B2aXRlanMvcGx1Z2luLXJlYWN0JztcclxuXHJcbmV4cG9ydCBkZWZhdWx0IGRlZmluZUNvbmZpZyh7XHJcbiAgcGx1Z2luczogW3JlYWN0KCldLFxyXG4gIHJlc29sdmU6IHtcclxuICAgIGFsaWFzOiB7XHJcbiAgICAgICdAJzogJy9zcmMnLFxyXG4gICAgfSxcclxuICB9LFxyXG4gIHNlcnZlcjoge1xyXG4gICAgcG9ydDogODAwMCxcclxuICAgIHN0cmljdFBvcnQ6IHRydWUsXHJcbiAgICBob3N0OiB0cnVlLCAvLyBBbGxvdyBleHRlcm5hbCBjb25uZWN0aW9uc1xyXG4gICAgb3BlbjogdHJ1ZSxcclxuICAgIGNvcnM6IHRydWUsXHJcbiAgICAvLyBBbGxvdyBuZ3JvayBhbmQgbG9jYWxob3N0XHJcbiAgICBhbGxvd2VkSG9zdHM6IFtcclxuICAgICAgJ2xvY2FsaG9zdCcsXHJcbiAgICAgICcxMjcuMC4wLjEnLFxyXG4gICAgICAndW5sYXVnaGluZy1qdW5pZS11bmNyZWF0aXZlLm5ncm9rLWZyZWUuZGV2J1xyXG4gICAgXSxcclxuICAgIHByb3h5OiB7XHJcbiAgICAgICcvYXBpJzoge1xyXG4gICAgICAgIHRhcmdldDogJ2h0dHA6Ly9sb2NhbGhvc3Q6MzAwMScsXHJcbiAgICAgICAgY2hhbmdlT3JpZ2luOiB0cnVlLFxyXG4gICAgICB9LFxyXG4gICAgfSxcclxuICB9LFxyXG59KTtcclxuIl0sCiAgIm1hcHBpbmdzIjogIjtBQUF1akIsU0FBUyxvQkFBb0I7QUFDcGxCLE9BQU8sV0FBVztBQUVsQixJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixTQUFTLENBQUMsTUFBTSxDQUFDO0FBQUEsRUFDakIsU0FBUztBQUFBLElBQ1AsT0FBTztBQUFBLE1BQ0wsS0FBSztBQUFBLElBQ1A7QUFBQSxFQUNGO0FBQUEsRUFDQSxRQUFRO0FBQUEsSUFDTixNQUFNO0FBQUEsSUFDTixZQUFZO0FBQUEsSUFDWixNQUFNO0FBQUE7QUFBQSxJQUNOLE1BQU07QUFBQSxJQUNOLE1BQU07QUFBQTtBQUFBLElBRU4sY0FBYztBQUFBLE1BQ1o7QUFBQSxNQUNBO0FBQUEsTUFDQTtBQUFBLElBQ0Y7QUFBQSxJQUNBLE9BQU87QUFBQSxNQUNMLFFBQVE7QUFBQSxRQUNOLFFBQVE7QUFBQSxRQUNSLGNBQWM7QUFBQSxNQUNoQjtBQUFBLElBQ0Y7QUFBQSxFQUNGO0FBQ0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
