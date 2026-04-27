const bcrypt = require('bcryptjs');
const db = require('./config/database');

async function testPassword() {
  try {
    console.log('=== TEST PASSWORD ===\n');
    
    // Get current user
    const [users] = await db.query(
      'SELECT id, email, password FROM users WHERE email = ?',
      ['admin@siakad.com']
    );
    
    if (users.length === 0) {
      console.log('❌ User not found!');
      return;
    }
    
    const user = users[0];
    console.log('Email:', user.email);
    console.log('Current hash:', user.password);
    console.log('');
    
    // Test current hash
    const testPass = 'admin123';
    const isValid = await bcrypt.compare(testPass, user.password);
    console.log('Test password "admin123":', isValid ? '✅ VALID' : '❌ INVALID');
    
    if (!isValid) {
      console.log('\n🔄 Generating new hash...');
      const newHash = await bcrypt.hash(testPass, 10);
      console.log('New hash:', newHash);
      
      // Update database
      await db.query('UPDATE users SET password = ? WHERE email = ?', [newHash, 'admin@siakad.com']);
      console.log('✅ Database updated!');
      
      // Verify
      const [updated] = await db.query('SELECT password FROM users WHERE email = ?', ['admin@siakad.com']);
      const verify = await bcrypt.compare(testPass, updated[0].password);
      console.log('Verify after update:', verify ? '✅ SUCCESS' : '❌ FAILED');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

testPassword();
