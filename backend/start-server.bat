@echo off
echo ========================================
echo   SIAKAD Backend Server
echo ========================================
echo.

REM Check if node_modules exists
if not exist "node_modules\" (
    echo [INFO] Installing dependencies...
    call npm install
    echo.
)

echo [INFO] Starting server...
echo [INFO] Server will run on http://localhost:3000
echo [INFO] Press Ctrl+C to stop the server
echo.

call npm run dev

pause
