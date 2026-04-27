@echo off
chcp 65001 >nul
echo ==========================================
echo    UPDATE NGROK URL - API CONFIG
echo ==========================================
echo.

set /p NGROK_URL="Masukkan URL ngrok (contoh: https://abcd1234.ngrok-free.app): "

if "%NGROK_URL%"=="" (
    echo [!] URL tidak boleh kosong!
    pause
    exit /b 1
)

:: Remove trailing slash if exists
if "%NGROK_URL:~-1%"=="/" set NGROK_URL=%NGROK_URL:~0,-1%

set CONFIG_FILE=%~dp0lib\config\api_config.dart

echo [*] Mengupdate file: %CONFIG_FILE%

:: Check if file exists
if not exist "%CONFIG_FILE%" (
    echo [!] File tidak ditemukan: %CONFIG_FILE%
    pause
    exit /b 1
)

:: Create backup
copy "%CONFIG_FILE%" "%CONFIG_FILE%.backup" >nul 2>&1

:: Update the baseUrl line
powershell -Command "(Get-Content '%CONFIG_FILE%') -replace 'static const String baseUrl = .*;', 'static const String baseUrl = ''%NGROK_URL%'';' | Set-Content '%CONFIG_FILE%'"

if %errorlevel% neq 0 (
    echo [!] Gagal update file, restore backup...
    copy "%CONFIG_FILE%.backup" "%CONFIG_FILE%" >nul 2>&1
    pause
    exit /b 1
)

echo [✓] URL berhasil diupdate!
echo [*] baseUrl sekarang: %NGROK_URL%
echo [*] Hot restart Flutter app sekarang
echo.

:: Show current setting
echo [*] Isi file sekarang:
powershell -Command "Get-Content '%CONFIG_FILE%' | Select-String 'baseUrl' | ForEach-Object { Write-Host $_ }"

echo.
pause
