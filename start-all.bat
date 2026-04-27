@echo off
chcp 65001 >nul
echo ==========================================
echo    START SIAKAD + NGROK
echo ==========================================
echo.

:: Kill existing processes
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM ngrok.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [1/4] Mengecek ngrok...
where ngrok >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Ngrok belum terinstall!
    echo [*] Jalankan: npm install -g ngrok
    pause
    exit /b 1
)
echo [✓] Ngrok ditemukan

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

echo [✓] Backend berjalan!
echo.
echo [4/4] Memulai Ngrok...
echo ==========================================
echo [*] COPY URL https://xxxx.ngrok-free.app
echo [*] Paste ke: lib/config/api_config.dart
echo [*] Ganti: baseUrl = 'https://xxxx.ngrok-free.app'
echo [*] Tekan Ctrl+C untuk berhenti
echo ==========================================
echo.
ngrok http 3000
