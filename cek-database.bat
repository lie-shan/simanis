@echo off
echo ======================================
echo    CEK DATABASE LOGIN
echo ======================================
echo.

echo [1] Cek apakah user admin ada...
cd /d "%~dp0\backend"

node -e "
const db = require('./config/database');
async function cek() {
  try {
    const [users] = await db.query('SELECT id, nama, email, password, role, status FROM users WHERE email = ?', ['admin@siakad.com']);
    if (users.length === 0) {
      console.log('❌ User admin@siakad.com TIDAK DITEMUKAN!');
      console.log('   Solusi: Reset database dengan server.bat -> pilih 2');
    } else {
      const u = users[0];
      console.log('✅ User ditemukan:');
      console.log('   ID:', u.id);
      console.log('   Nama:', u.nama);
      console.log('   Email:', u.email);
      console.log('   Role:', u.role);
      console.log('   Status:', u.status);
      console.log('   Password hash:', u.password.substring(0, 30) + '...');
      
      // Cek hash format
      if (u.password.startsWith('\$2a\$10\$N9qo8u')) {
        console.log('   ✅ Password hash BENAR (admin123)');
      } else if (u.password.startsWith('\$2a\$')) {
        console.log('   ⚠️  Hash bcrypt tapi berbeda (bukan admin123)');
      } else {
        console.log('   ❌ Password hash SALAH!');
      }
    }
  } catch(e) {
    console.log('Error:', e.message);
  }
  process.exit();
}
cek();
"

echo.
echo ======================================
pause
