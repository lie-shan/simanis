@echo off
chcp 65001 >nul
echo ==========================================
echo    SETUP CLOUDFLARE TUNNEL - SIAKAD
echo ==========================================
echo.

:: Check cloudflared
where cloudflared >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Menginstall Cloudflared...
    winget install --id Cloudflare.cloudflared
    if %errorlevel% neq 0 (
        echo [!] Gagal install. Download manual dari:
        echo    https://github.com/cloudflare/cloudflared/releases
        pause
        exit /b 1
    )
    echo [✓] Cloudflared terinstall!
    echo [*] Restart terminal ini setelah install
    pause
    exit /b 0
)

echo [✓] Cloudflared sudah terinstall
echo.

:: Menu
:MENU
cls
echo ==========================================
echo    SETUP CLOUDFLARE TUNNEL
echo ==========================================
echo.
echo Pilih opsi:
echo.
echo 1. Login ke Cloudflare (sekali saja)
echo 2. Buat tunnel "siakad"
echo 3. Setup domain untuk tunnel
echo 4. Lihat daftar tunnel
echo 5. Hapus tunnel
echo 6. Exit
echo.
set /p CHOICE="Pilihan (1-6): "

if "%CHOICE%"=="1" goto LOGIN
if "%CHOICE%"=="2" goto CREATE
if "%CHOICE%"=="3" goto DNS
if "%CHOICE%"=="4" goto LIST
if "%CHOICE%"=="5" goto DELETE
if "%CHOICE%"=="6" goto EXIT

goto MENU

:LOGIN
echo.
echo [*] Buka browser untuk login...
echo [*] Pilih domain yang ingin digunakan
echo [*] Copy certificate yang muncul
echo.
cloudflared tunnel login
echo.
echo [✓] Login selesai!
pause
goto MENU

:CREATE
echo.
set /p TUNNEL_NAME="Nama tunnel (default: siakad): "
if "%TUNNEL_NAME%"=="" set TUNNEL_NAME=siakad
echo [*] Membuat tunnel "%TUNNEL_NAME%"...
cloudflared tunnel create %TUNNEL_NAME%
echo.
echo [✓] Tunnel dibuat!
echo [*] Catat Tunnel ID yang muncul di atas
echo [*] Lanjut ke opsi 3 untuk setup domain
pause
goto MENU

:DNS
echo.
set /p TUNNEL_NAME="Nama tunnel (default: siakad): "
if "%TUNNEL_NAME%"=="" set TUNNEL_NAME=siakad
set /p DOMAIN="Masukkan domain (contoh: siakad.yourdomain.com): "
if "%DOMAIN%"=="" (
    echo [!] Domain tidak boleh kosong!
    pause
    goto MENU
)
echo [*] Routing %DOMAIN% ke tunnel %TUNNEL_NAME%...
cloudflared tunnel route dns %TUNNEL_NAME% %DOMAIN%
echo.
echo [✓] DNS route dibuat!
echo [*] Update api_config.dart:
echo    baseUrl = 'https://%DOMAIN%'
pause
goto MENU

:LIST
echo.
echo [*] Daftar tunnel:
cloudflared tunnel list
echo.
pause
goto MENU

:DELETE
echo.
set /p TUNNEL_NAME="Nama tunnel yang akan dihapus: "
if "%TUNNEL_NAME%"=="" goto MENU
echo [*] Menghapus tunnel %TUNNEL_NAME%...
cloudflared tunnel delete %TUNNEL_NAME%
echo [✓] Tunnel dihapus!
pause
goto MENU

:EXIT
echo.
echo [*] Selesai!
echo [*] Jalankan: start-cloudflare.bat untuk mulai tunnel
echo.
pause
exit /b 0
