@echo off
chcp 65001 >nul
echo ==========================================
echo    SIMANIS PRODUCTION MODE
echo    https://api.sinan.my.id
echo ==========================================
echo.

:: Check prerequisites
where cloudflared >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Cloudflared belum terinstall!
    echo [*] Install: winget install --id Cloudflare.cloudflared
    pause
    exit /b 1
)

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Node.js belum terinstall!
    echo [*] Install dari https://nodejs.org
    pause
    exit /b 1
)

:: Check if tunnel exists
cloudflared tunnel list | findstr "SIMANIS" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Tunnel SIMANIS belum dibuat!
    echo.
    echo [*] Jalankan setup dulu:
    echo     setup-permanent-tunnel.bat
echo.
    echo [*] Atau manual:
    echo     1. cloudflared tunnel login
    echo     2. cloudflared tunnel create SIMANIS
    echo     3. cloudflared tunnel route dns SIMANIS api.sinan.my.id
    echo.
    pause
    exit /b 1
)

:: Check backend dependencies
echo [*] Mengecek backend dependencies...
if not exist "%~dp0backend\node_modules" (
    echo [*] Installing backend dependencies...
    cd "%~dp0backend"
    npm install
    cd "%~dp0"
)

:: Kill existing processes (clean start)
echo [*] Membersihkan proses lama...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM cloudflared.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: Start Backend
echo.
echo [1/3] Memulai Backend Server...
start "" /D "%~dp0backend" cmd /k "npm start"

:: Wait for backend
echo [*] Menunggu backend siap (5 detik)...
timeout /t 5 /nobreak >nul

:: Check backend health
echo [*] Mengecek backend health...
curl -s http://localhost:3000/health >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Backend belum respons, menunggu 5 detik lagi...
    timeout /t 5 /nobreak >nul
)

curl -s http://localhost:3000/health >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Backend masih belum siap. Periksa manual di: http://localhost:3000
) else (
    echo [✓] Backend berjalan di http://localhost:3000
)

:: Start Tunnel
echo.
echo [2/3] Memulai Cloudflare Tunnel...
echo [*] Domain: https://api.sinan.my.id
echo [*] Local:  http://localhost:3000
echo.
echo ==========================================
echo    TEKAN CTRL+C UNTUK BERHENTI
echo ==========================================
echo.

:: Run tunnel with config
cloudflared tunnel --config "%~dp0cloudflare\config.yml" run SIMANIS

:: Cleanup after tunnel stops
echo.
echo [*] Tunnel dihentikan
echo [*] Membersihkan proses...
taskkill /F /IM node.exe >nul 2>&1
echo [✓] Semua proses dihentikan
echo.
pause
