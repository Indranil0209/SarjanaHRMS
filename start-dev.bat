@echo off
echo ========================================
echo  Sarjana HR Tech - Development Server
echo ========================================
echo.
echo Starting backend server...
start "Backend (Port 3001)" cmd /k "cd backend && echo Backend starting on http://localhost:3001 && npm run dev"

timeout /t 2 /nobreak >nul

echo Starting frontend server...
start "Frontend (Port 8000)" cmd /k "cd frontend && echo Frontend starting on http://localhost:8000 && npm run dev"

echo.
echo ========================================
echo  Servers are starting!
echo ========================================
echo.
echo - Backend API:  http://localhost:3001
echo - Frontend App: http://localhost:8000
echo.
echo The frontend will automatically open in your browser.
echo Press Ctrl+C in each terminal to stop the servers.
echo.
pause
