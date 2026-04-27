@echo off
chcp 65001 >nul
echo ==========================================
echo    START NGROK - SIAKAD BACKEND
echo ==========================================
echo.

echo [1/3] Mengecek backend server...
curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Backend belum jalan! Mulai backend dulu...
    echo.
    start "" /D "%~dp0backend" cmd /k "npm start"
    echo [*] Menunggu backend start (5 detik)...
    timeout /t 5 /nobreak >nul
) else (
    echo [✓] Backend sudah berjalan di port 3000
)

echo.
echo [2/3] Mengecek ngrok...
where ngrok >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Ngrok belum terinstall!
    echo [*] Install ngrok dengan: npm install -g ngrok
    pause
    exit /b 1
)

echo [✓] Ngrok ditemukan
echo.
echo [3/3] Memulai ngrok...
echo [*] URL akan muncul di bawah, copy ke api_config.dart
echo [*] Tekan Ctrl+C untuk berhenti
echo.
echo ==========================================
ngrok http 3000
