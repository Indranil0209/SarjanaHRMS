# Sarjana HR Tech - Separated Architecture

This repository has been refactored into a clean **frontend/backend separation** for better maintainability and scalability.

## 📁 Directory Structure

```
SarjanaHRMS-main/
├── frontend/              # React + Vite Application
│   ├── src/
│   │   ├── components/   # UI components
│   │   ├── pages/        # Page components
│   │   ├── context/      # React Context providers
│   │   ├── hooks/        # Custom React hooks
│   │   ├── utils/        # Utility functions
│   │   ├── lib/          # External library configurations
│   │   └── ...
│   ├── public/           # Static assets
│   ├── package.json
│   └── vite.config.js
│
├── backend/              # Express.js API Server
│   ├── src/
│   │   ├── api/         # API routes and controllers
│   │   └── middleware/  # Express middleware
│   ├── database/        # SQL schemas and migrations
│   ├── package.json
│   └── .env.example
│
└── [Documentation Files]
```

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ installed
- npm or yarn package manager
- Supabase account configured

### Installation

#### 1. Install Frontend Dependencies
```bash
cd frontend
npm install
```

#### 2. Install Backend Dependencies
```bash
cd ../backend
npm install
```

### Running the Application

#### Option 1: Run Both (Recommended)
Open **two separate terminals**:

**Terminal 1 - Frontend:**
```bash
cd frontend
npm run dev
```
Frontend will run on `http://localhost:8000`

**Terminal 2 - Backend:**
```bash
cd backend
npm run dev
```
Backend will run on `http://localhost:3001`

#### Option 2: Frontend Only (with Proxy)
The frontend is configured to proxy `/api` requests to the backend automatically.

### Environment Setup

#### Frontend (.env)
Create `frontend/.env` file:
```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_API_URL=http://localhost:3001/api
```

#### Backend (.env)
Create `backend/.env` file:
```env
PORT=3001
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_service_role_key
```

## 🔧 Available Scripts

### Frontend
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

### Backend
- `npm run dev` - Start development server with auto-reload
- `npm start` - Start production server
- `npm run migrate` - Run database migrations

## 🌐 Architecture Details

### Frontend Stack
- **React 18.2** - UI framework
- **Vite 4.5** - Build tool and dev server
- **React Router 6.18** - Client-side routing
- **Tailwind CSS 3.3** - Styling
- **Supabase JS Client** - Database connectivity
- **Recharts** - Data visualization
- **Framer Motion** - Animations
- **Lucide React** - Icons

### Backend Stack
- **Express.js 4.18** - Web framework
- **CORS** - Cross-origin resource sharing
- **Supabase JS Client** - Database operations
- **Multi-tenant Middleware** - Company data isolation

### API Endpoints
The backend exposes RESTful API endpoints under `/api`:
- `/api/company/*` - Company management
- `/api/payroll/*` - Payroll processing
- `/api/salary/*` - Salary configuration
- `/api/health` - Health check

### Proxy Configuration
Frontend development server proxies all `/api` requests to `http://localhost:3001` to avoid CORS issues during development.

## 🔐 Security Notes

1. **Never commit `.env` files** - Use `.env.example` as template
2. **Use service role key only in backend** - Keep it secure
3. **Anon key is safe in frontend** - Limited permissions
4. **CORS is configured** - Only allows frontend origin

## 📦 Deployment

### Frontend Deployment
Build the frontend:
```bash
cd frontend
npm run build
```
Deploy the `dist/` folder to your hosting provider (Vercel, Netlify, etc.)

### Backend Deployment
Deploy to Heroku, Railway, Render, or any Node.js hosting:
```bash
cd backend
# Set environment variables in hosting platform
npm start
```

## 🗄️ Database

Database schemas and migrations are located in `backend/database/`:
- `schema.sql` - Complete database schema
- `demo-data.sql` - Sample data for testing
- `migrations/` - Version-controlled migrations

Run migrations:
```bash
cd backend
npm run migrate
```

## 📝 Key Features

✅ **Clean Separation** - Frontend and backend are independent
✅ **No Breaking Changes** - All features work identically
✅ **Multi-tenancy Preserved** - Company data isolation maintained
✅ **Development Friendly** - Hot reload in both frontend and backend
✅ **Production Ready** - Optimized builds and proper error handling

## 🛠️ Troubleshooting

### Frontend won't start
- Ensure you're in the `frontend` directory
- Run `npm install` first
- Check if port 8000 is available

### Backend API not responding
- Ensure backend is running on port 3001
- Check `.env` configuration
- Verify Supabase credentials

### CORS errors
- Backend CORS is configured for `http://localhost:8000`
- If using different port, update `backend/src/api/server.js`

### Import errors
- All imports have been updated to reflect new structure
- No frontend code should import from backend directly

## 📚 Documentation

Detailed documentation available in root directory:
- `IMPLEMENTATION_SUMMARY.md` - Implementation overview
- `MULTI_TENANT_IMPLEMENTATION.md` - Multi-tenancy details
- `SUPABASE_SETUP.md` - Supabase configuration guide
- `DEMO_CREDENTIALS.md` - Test credentials
- `STEP_BY_STEP_INSTRUCTIONS.md` - Setup walkthrough

## 🎯 Next Steps

1. Install dependencies in both directories
2. Configure environment variables
3. Start both servers
4. Access application at `http://localhost:8000`

For questions or issues, refer to the original documentation files in the root directory.
