@echo off
setlocal EnableDelayedExpansion

echo ======================================
echo    SIAKAD SERVER MANAGER
echo ======================================
echo.
echo Pilih opsi:
echo [1] Jalankan Server (normal)
echo [2] Reset Database + Jalankan Server
echo [3] Hentikan Server
echo [4] Test Login
echo.
set /p pilihan="Pilih (1-4): "

if "%pilihan%"=="1" goto RUN
if "%pilihan%"=="2" goto RESET
if "%pilihan%"=="3" goto STOP
if "%pilihan%"=="4" goto TEST
goto END

:STOP
echo.
echo [STOP] Menghentikan server...
taskkill /F /IM node.exe 2>nul
echo [OK] Server dihentikan
goto END

:RESET
echo.
echo [RESET] Reset database...
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul

cd /d "%~dp0\backend"

echo - Drop database lama...
echo DROP DATABASE IF EXISTS siakad_db; CREATE DATABASE siakad_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; > reset.sql
"C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe" -u root < reset.sql 2>nul
if !errorlevel! neq 0 (
    mysql -u root < reset.sql 2>nul
)

echo - Import schema baru...
"C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe" -u root siakad_db < database\schema.sql 2>nul
if !errorlevel! neq 0 (
    mysql -u root siakad_db < database\schema.sql
)

del reset.sql 2>nul
echo [OK] Database direset
echo.

:RUN
echo [START] Menjalankan server...
cd /d "%~dp0\backend"
call npm install >nul 2>&1
echo.
echo ======================================
echo Server berjalan di:
echo - http://localhost:3000
echo - http://192.168.1.177:3000 (HP)
echo.
echo Login: admin@siakad.com / admin123
echo Tekan Ctrl+C untuk berhenti
echo ======================================
echo.
npm start
goto END

:TEST
echo.
echo [TEST] Login admin@siakad.com...
curl.exe -s -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d "{\"email\":\"admin@siakad.com\",\"password\":\"admin123\"}"
echo.
echo.
pause
goto END

:END
endlocal
