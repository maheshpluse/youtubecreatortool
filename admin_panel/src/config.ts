// In production the admin panel is served from the same origin as the API
// (https://vidseokit.com/adminx + /api, see nginx_vidseokit.conf), so an
// empty base works there. For local dev, point this at the backend with a
// .env.local: VITE_API_URL=http://localhost:8000
export const API_BASE_URL = import.meta.env.VITE_API_URL ?? '';
