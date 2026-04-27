@echo off
echo ======================================
echo    FIX PASSWORD ADMIN
echo ======================================
echo.

cd /d "%~dp0\backend"

echo [1] Test bcrypt compare...
node -e "
const bcrypt = require('bcryptjs');
const db = require('./config/database');

async function test() {
  try {
    const [users] = await db.query('SELECT email, password FROM users WHERE email = ?', ['admin@siakad.com']);
    if (users.length === 0) {
      console.log('❌ User tidak ditemukan');
      return;
    }
    
    const hash = users[0].password;
    console.log('Hash di DB:', hash.substring(0, 50) + '...');
    
    // Test compare
    const valid = await bcrypt.compare('admin123', hash);
    console.log('Password admin123 valid?', valid);
    
    if (!valid) {
      console.log('\\n🔄 Generate hash baru...');
      const newHash = await bcrypt.hash('admin123', 10);
      console.log('Hash baru:', newHash);
      
      // Update database
      await db.query('UPDATE users SET password = ? WHERE email = ?', [newHash, 'admin@siakad.com']);
      console.log('✅ Password diupdate!');
      
      // Verify again
      const [updated] = await db.query('SELECT password FROM users WHERE email = ?', ['admin@siakad.com']);
      const valid2 = await bcrypt.compare('admin123', updated[0].password);
      console.log('Verifikasi ulang:', valid2 ? '✅ BERHASIL' : '❌ GAGAL');
    }
  } catch(e) {
    console.log('Error:', e.message);
  }
  process.exit();
}

test();
"

echo.
echo ======================================
pause
