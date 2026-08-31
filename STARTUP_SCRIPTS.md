# Sarjana HR Tech - Quick Start Scripts

## Windows (.bat)

### start-dev.bat
```batch
@echo off
echo Starting Sarjana HR Tech Development Environment...
echo.

REM Start Backend
start "Backend Server" cmd /k "cd backend && npm run dev"

REM Wait a moment for backend to initialize
timeout /t 3 /nobreak >nul

REM Start Frontend
start "Frontend Server" cmd /k "cd frontend && npm run dev"

echo.
echo Both servers are starting!
echo - Backend: http://localhost:3001
echo - Frontend: http://localhost:8000
echo.
echo Press any key to exit this window...
pause >nul
```

## Linux/MacOS (.sh)

### start-dev.sh
```bash
#!/bin/bash

echo "Starting Sarjana HR Tech Development Environment..."
echo ""

# Start Backend in new terminal
gnome-terminal --title="Backend Server" -- bash -c "cd backend && npm run dev; exec bash"

# Wait a moment for backend to initialize
sleep 2

# Start Frontend in new terminal
gnome-terminal --title="Frontend Server" -- bash -c "cd frontend && npm run dev; exec bash"

echo ""
echo "Both servers are starting!"
echo "- Backend: http://localhost:3001"
echo "- Frontend: http://localhost:8000"
echo ""
```

## Usage

### Windows
Double-click `start-dev.bat` or run:
```cmd
start-dev.bat
```

### Linux/MacOS
Make executable and run:
```bash
chmod +x start-dev.sh
./start-dev.sh
```

## Manual Start (All Platforms)

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

## Access the Application

Once both servers are running:
- **Frontend**: http://localhost:8000
- **Backend API**: http://localhost:3001/api/health

The frontend will automatically proxy API requests to the backend.
