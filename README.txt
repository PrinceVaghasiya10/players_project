Players Manager - Full project (backend + frontend)

Structure:
project-root/
├─ backend/   (Express + Postgres)
├─ frontend/  (React app)

Quick start (backend):
1. Open terminal:
   cd backend
   npm install
   cp .env.example .env
   # edit .env and set your DB credentials
   npm run dev

Quick start (frontend):
1. In another terminal:
   cd frontend
   npm install
   npm start

Frontend expects backend at:
REACT_APP_API_URL=http://localhost:4000

If you prefer to serve frontend from backend in production:
1. cd frontend
   npm run build
2. Start backend (server.js already serves frontend/build if present)

Notes:
- This zip excludes node_modules. Run npm install in both folders.
- If you want Tailwind styling, follow Tailwind setup in the frontend folder (I left directives commented).
