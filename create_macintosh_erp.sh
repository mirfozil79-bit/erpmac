#!/usr/bin/env bash
set -e

# Loyiha nomi
PROJECT=erpmac
BACKEND=$PROJECT/backend
FRONTEND=$PROJECT/frontend

echo "📂 Loyihaning papkalarini yaratamiz..."
rm -rf $PROJECT
mkdir -p $BACKEND $FRONTEND

# ==== BACKEND package.json ====
cat > $BACKEND/package.json <<'EOF'
{
  "name": "erpmac-backend",
  "version": "0.1.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "express": "^4.18.2",
    "pg": "^8.11.0",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
EOF

# ==== BACKEND .env.example ====
cat > $BACKEND/.env.example <<'EOF'
PORT=4000
DATABASE_URL=postgresql://postgres:postgres@db:5432/erpmac
JWT_SECRET=replace_with_secret
EOF

# ==== BACKEND index.js ====
cat > $BACKEND/index.js <<'EOF'
require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const PORT = process.env.PORT || 4000;
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/ping', (req, res) => res.json({ ok: true, time: new Date().toISOString() }));

app.listen(PORT, () => console.log(`Backend running on ${PORT}`));
EOF

# ==== docker-compose.yml ====
cat > $PROJECT/docker-compose.yml <<'EOF'
version: "3.8"
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: erpmac
    ports:
      - "5432:5432"
  backend:
    build: ./backend
    ports:
      - "4000:4000"
    depends_on:
      - db
EOF

# ==== BACKEND Dockerfile ====
cat > $BACKEND/Dockerfile <<'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
EXPOSE 4000
CMD ["npm", "start"]
EOF

# ==== FRONTEND package.json ====
cat > $FRONTEND/package.json <<'EOF'
{
  "name": "erpmac-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "axios": "^1.4.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.14.1"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "@vitejs/plugin-react": "^4.0.0"
  }
}
EOF

mkdir -p $FRONTEND/src
cat > $FRONTEND/index.html <<'EOF'
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>ERPmac</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > $FRONTEND/src/main.jsx <<'EOF'
import React from 'react'
import { createRoot } from 'react-dom/client'

function App(){
  return (
    <div style={{padding:20}}>
      <h1>ERPmac Demo</h1>
      <p>Frontend ishlayapti ✅</p>
    </div>
  )
}

createRoot(document.getElementById('root')).render(<App />)
EOF

echo "✅ ERPmac loyihasi yaratildi."
echo "Endi GitHub'ga yuklash uchun:"
echo "git add . && git commit -m 'Initial scaffold' && git push origin main"
