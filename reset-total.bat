@echo off
echo ======================================
echo    RESET TOTAL DATABASE
echo ======================================
echo.

echo [1] Matikan semua server...
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul
echo [OK]
echo.

echo [2] Reset database MySQL...
cd /d "%~dp0\backend"

node -e "
const mysql = require('mysql2/promise');
async function reset() {
  try {
    const conn = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      multipleStatements: true
    });
    await conn.query('DROP DATABASE IF EXISTS siakad_db');
    await conn.query('CREATE DATABASE siakad_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
    console.log('[OK] Database dibuat ulang');
    await conn.end();
  } catch(e) {
    console.log('Error (mencoba tanpa password):', e.message);
    try {
      const conn = await mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: 'root',
        multipleStatements: true
      });
      await conn.query('DROP DATABASE IF EXISTS siakad_db');
      await conn.query('CREATE DATABASE siakad_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
      console.log('[OK] Database dibuat ulang (dengan password root)');
      await conn.end();
    } catch(e2) {
      console.log('Error:', e2.message);
    }
  }
  process.exit();
}
reset();
"

echo.
echo [3] Import schema dengan data lengkap...
"C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe" -u root siakad_db < database\schema.sql 2>nul
if %errorlevel% neq 0 (
    mysql -u root siakad_db < database\schema.sql
)
echo [OK] Data diimport
echo.

echo [4] Jalankan server...
call npm install >nul 2>&1
echo.
echo ======================================
echo ✅ RESET SELESAI!
echo.
echo Login: admin@siakad.com / admin123
echo ======================================
echo.
npm start
