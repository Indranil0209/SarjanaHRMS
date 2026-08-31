# 🚀 Quick Start - Sarjana HR Tech

## ⚡ Fastest Way to Get Started

### Windows Users (Easiest)
**Double-click this file:** `start-dev.bat`

That's it! Both servers will start automatically and your browser will open.

---

## 📋 Prerequisites Checklist

Before starting, make sure you have:

- [ ] Node.js 16+ installed ([Download here](https://nodejs.org/))
- [ ] npm comes with Node.js
- [ ] Supabase account set up
- [ ] Git cloned this repository

---

## 🔧 First-Time Setup (5 Minutes)

### Step 1: Install Dependencies

**Frontend:**
```bash
cd frontend
npm install
```

**Backend:**
```bash
cd ../backend
npm install
```

### Step 2: Configure Environment

**Frontend (.env):**
```bash
cd frontend
copy .env.example .env
```

Edit `frontend/.env`:
```env
VITE_SUPABASE_URL=your_actual_supabase_url
VITE_SUPABASE_ANON_KEY=your_actual_anon_key
VITE_API_URL=http://localhost:3001/api
```

**Backend (.env):**
```bash
cd ../backend
copy .env.example .env
```

Edit `backend/.env`:
```env
PORT=3001
SUPABASE_URL=your_actual_supabase_url
SUPABASE_SERVICE_KEY=your_actual_service_role_key
```

### Step 3: Start Development Servers

**Option A: Use the batch file (Windows)**
```bash
# From root directory
start-dev.bat
```

**Option B: Manual (Two Terminals)**

Terminal 1 - Backend:
```bash
cd backend
npm run dev
```

Terminal 2 - Frontend:
```bash
cd frontend
npm run dev
```

---

## 🌐 Access Your Application

Once both servers are running:

- **Frontend App**: http://localhost:8000
- **Backend API**: http://localhost:3001/api/health

The frontend should open automatically in your browser.

---

## ✅ Verify It Works

1. **Login page appears** at http://localhost:8000
2. **No console errors** in browser DevTools
3. **Backend responds** when visiting /api/health
4. **Can login** with test credentials
5. **Dashboard loads** after login

---

## 🆘 Troubleshooting

### "Port already in use" error
**Solution:** Close any other apps using ports 8000 or 3001, or change the port in config files.

### "Cannot find module" errors
**Solution:** Run `npm install` in both `frontend` and `backend` directories.

### Supabase connection errors
**Solution:** Double-check your `.env` values match your Supabase project settings.

### CORS errors
**Solution:** Make sure backend is running first, then start frontend.

### Blank page / white screen
**Solution:** Check browser console for errors. Usually missing environment variables.

---

## 📚 Need More Help?

- **Detailed Architecture**: See `ARCHITECTURE_REFACTOR.md`
- **Complete Documentation**: See `REFACTORING_COMPLETE_SUMMARY.md`
- **Step-by-Step Guide**: See `STEP_BY_STEP_INSTRUCTIONS.md`
- **Supabase Setup**: See `SUPABASE_SETUP.md`
- **Demo Credentials**: See `DEMO_CREDENTIALS.md`

---

## 🎯 What You Get

After setup, you'll have access to:

✅ Employee Dashboard
✅ HR Manager Dashboard  
✅ Admin Dashboard
✅ Payroll Management
✅ Attendance Tracking
✅ Leave Management
✅ Task Management
✅ Expense Approvals
✅ Performance Reviews
✅ Reports & Analytics
✅ Multi-tenant Architecture

---

## 💻 Development Commands

### Frontend
```bash
npm run dev      # Start dev server (port 8000)
npm run build    # Build for production
npm run preview  # Preview production build
npm run lint     # Check code quality
```

### Backend
```bash
npm run dev      # Start API server with auto-reload
npm start        # Start production server
npm run migrate  # Run database migrations
```

---

## 🎉 Success!

If you can see the login page and no errors in console, you're all set! 

Start exploring the features, and refer to the documentation files for detailed guides on each module.

**Happy coding!** 🚀
