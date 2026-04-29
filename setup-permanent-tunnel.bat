@echo off
chcp 65001 >nul
echo ==========================================
echo    SETUP PERMANENT TUNNEL - SIMANIS
echo    Domain: api.sinan.my.id
echo ==========================================
echo.

:: Check cloudflared
where cloudflared >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Cloudflared belum terinstall!
    echo [*] Install dengan: winget install --id Cloudflare.cloudflared
    echo [*] Atau download dari: https://github.com/cloudflare/cloudflared/releases
    pause
    exit /b 1
)
echo [✓] Cloudflared ditemukan
echo.

:: Menu utama
:MENU
cls
echo ==========================================
echo    SETUP PERMANENT TUNNEL
echo ==========================================
echo.
echo Pilih opsi setup:
echo.
echo 1. Login ke Cloudflare (sekali saja per komputer)
echo 2. Buat tunnel SIMANIS (sekali saja)
echo 3. Setup subdomain api.sinan.my.id
echo 4. Install sebagai Windows Service (auto-start)
echo 5. Jalankan tunnel (tanpa service)
echo 6. Cek status tunnel
echo 7. Update/reinstall service
echo 8. Uninstall service
echo 9. Exit
echo.
set /p CHOICE="Pilihan (1-9): "

if "%CHOICE%"=="1" goto LOGIN
if "%CHOICE%"=="2" goto CREATE
if "%CHOICE%"=="3" goto DNS
if "%CHOICE%"=="4" goto INSTALL_SERVICE
if "%CHOICE%"=="5" goto RUN_ONCE
if "%CHOICE%"=="6" goto STATUS
if "%CHOICE%"=="7" goto UPDATE_SERVICE
if "%CHOICE%"=="8" goto UNINSTALL_SERVICE
if "%CHOICE%"=="9" goto EXIT
goto MENU

:LOGIN
echo.
echo ==========================================
echo [*] LOGIN KE CLOUDFLARE
echo ==========================================
echo [*] Browser akan terbuka...
echo [*] Pilih domain sinan.my.id
echo [*] Authorize akses
echo.
cloudflared tunnel login
echo.
echo [✓] Login selesai!
echo [*] Certificate tersimpan di: %USERPROFILE%\.cloudflared\
echo.
pause
goto MENU

:CREATE
echo.
echo ==========================================
echo [*] MEMBUAT TUNNEL SIMANIS
echo ==========================================
echo [*] Tunnel ID akan muncul, catat untuk backup
echo.
cloudflared tunnel create SIMANIS
echo.
echo [✓] Tunnel SIMANIS dibuat!
echo [*] Catat Tunnel ID di atas
echo [*] File credentials: %USERPROFILE%\.cloudflared\<tunnel-id>.json
echo.
pause
goto MENU

:DNS
echo.
echo ==========================================
echo [*] SETUP DNS ROUTE
echo ==========================================
echo [*] Routing api.sinan.my.id ke SIMANIS
echo.
cloudflared tunnel route dns SIMANIS api.sinan.my.id
echo.
if %errorlevel% neq 0 (
    echo [!] Gagal setup DNS. Pastikan:
    echo     - Tunnel SIMANIS sudah dibuat
    echo     - Domain sinan.my.id aktif di Cloudflare
    echo     - Sudah login dengan akun yang benar
) else (
    echo [✓] DNS route berhasil dibuat!
    echo [*] api.sinan.my.id -> SIMANIS tunnel -> localhost:3000
    echo.
    echo ==========================================
    echo    UPDATE FLUTTER CONFIG
echo ==========================================
    echo [*] Ganti di lib/config/api_config.dart:
    echo     static const String baseUrl = 'https://api.sinan.my.id';
    echo.
)
echo.
pause
goto MENU

:INSTALL_SERVICE
echo.
echo ==========================================
echo [*] INSTALL WINDOWS SERVICE
echo ==========================================
echo [*] Service akan auto-start saat Windows boot
echo.

:: Check admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] PERLU RUN AS ADMINISTRATOR!
    echo [*] Klik kanan file ini -> Run as administrator
    pause
    goto MENU
)

:: Get cloudflared path
for /f "delims=" %%i in ('where cloudflared') do set CLOUDFLARED_PATH=%%i
echo [*] Cloudflared path: %CLOUDFLARED_PATH%

:: Install service
echo [*] Installing cloudflared service...
"%CLOUDFLARED_PATH%" service install
echo.

:: Configure service to use our tunnel
echo [*] Configuring service for SIMANIS tunnel...
"%CLOUDFLARED_PATH%" tunnel --config "%~dp0cloudflare\config.yml" run SIMANIS

echo.
echo [✓] Service berhasil diinstall!
echo [*] Service name: Cloudflared
echo [*] Startup type: Automatic
echo [*] Check status: services.msc atau opsi 6
echo.
echo [*] Manage service:
echo     - Start:   net start cloudflared
echo     - Stop:    net stop cloudflared
echo     - Status:  sc query cloudflared
pause
goto MENU

:RUN_ONCE
echo.
echo ==========================================
echo [*] JALANKAN TUNNEL (Sementara)
echo ==========================================
echo [*] Tunnel berjalan sampai window ditutup
echo [*] Tekan Ctrl+C untuk berhenti
echo.

:: Check config file exists
if not exist "%~dp0cloudflare\config.yml" (
    echo [!] File config.yml tidak ditemukan!
    echo [*] Pastikan file ada di: %~dp0cloudflare\config.yml
    pause
    goto MENU
)

echo [*] Menjalankan tunnel dengan config.yml...
echo [*] URL target: https://api.sinan.my.id
echo [*] Local service: localhost:3000
echo.
cloudflared tunnel --config "%~dp0cloudflare\config.yml" run SIMANIS

echo.
echo [*] Tunnel dihentikan
echo.
pause
goto MENU

:STATUS
echo.
echo ==========================================
echo [*] CEK STATUS TUNNEL
echo ==========================================
echo.
echo --- Daftar Tunnel ---
cloudflared tunnel list
echo.
echo --- DNS Routes ---
cloudflared tunnel route dns list
echo.
echo --- Service Status ---
sc query cloudflared 2>nul
echo.
pause
goto MENU

:UPDATE_SERVICE
echo.
echo ==========================================
echo [*] UPDATE/REINSTALL SERVICE
echo ==========================================
echo.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] PERLU RUN AS ADMINISTRATOR!
    pause
    goto MENU
)

echo [*] Stopping service...
net stop cloudflared >nul 2>&1

echo [*] Uninstalling old service...
cloudflared service uninstall >nul 2>&1

echo [*] Installing new service...
cloudflared service install

echo [*] Starting service...
net start cloudflared

echo.
echo [✓] Service updated!
echo.
pause
goto MENU

:UNINSTALL_SERVICE
echo.
echo ==========================================
echo [*] UNINSTALL SERVICE
echo ==========================================
echo.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] PERLU RUN AS ADMINISTRATOR!
    pause
    goto MENU
)

echo [*] Stopping service...
net stop cloudflared >nul 2>&1

echo [*] Uninstalling service...
cloudflared service uninstall

echo.
echo [✓] Service dihapus!
echo.
pause
goto MENU

:EXIT
echo.
echo ==========================================
echo [*] Setup selesai!
echo ==========================================
echo.
echo Ringkasan perintah berguna:
echo   - Jalankan sekali: setup-permanent-tunnel.bat -> pilih 5
echo   - Cek status: cloudflared tunnel list
echo   - Lihat log: tail -f cloudflared.log (jika di Linux/Mac)
echo   - Lihat log: type cloudflared.log (Windows)
echo.
pause
exit /b 0
