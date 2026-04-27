@echo off
chcp 65001 >nul
echo ==========================================
echo    START SIAKAD + CLOUDFLARE TUNNEL
echo ==========================================
echo.

:: Kill existing processes
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM cloudflared.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [1/4] Mengecek cloudflared...
where cloudflared >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Cloudflared belum terinstall!
    echo [*] Install dengan: winget install --id Cloudflare.cloudflared
    echo [*] Atau download: https://github.com/cloudflare/cloudflared/releases
    pause
    exit /b 1
)
echo [✓] Cloudflared ditemukan

echo.
echo [2/4] Memulai Backend Server...
start "" /D "%~dp0backend" cmd /k "echo [SIAKAD BACKEND] ^&^& npm start"

echo [*] Menunggu backend siap (8 detik)...
timeout /t 8 /nobreak >nul

echo.
echo [3/4] Mengecek backend...
curl -s http://localhost:3000/api/kelas >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Backend belum siap, tunggu sebentar...
    timeout /t 5 /nobreak >nul
)

echo [✓] Backend berjalan di port 3000!
echo.

:: Check if tunnel exists
echo [4/4] Mengecek Cloudflare Tunnel...
cloudflared tunnel list | findstr "siakad" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Tunnel "siakad" belum dibuat!
    echo.
    echo [*] Setup tunnel (sekali saja):
    echo    1. Login: cloudflared tunnel login
    echo    2. Create: cloudflared tunnel create siakad
    echo    3. Route: cloudflared tunnel route dns siakad siakad.yourdomain.com
    echo.
    echo [*] Ganti URL di api_config.dart setelah setup!
    pause
    exit /b 1
)

echo [✓] Tunnel "siakad" ditemukan!
echo.
echo ==========================================
echo [*] Memulai Cloudflare Tunnel...
echo [*] URL: https://siakad.yourdomain.com (atau sesuai setup)
echo [*] Tekan Ctrl+C untuk berhenti
echo ==========================================
echo.
cloudflared tunnel run siakad
