const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Import routes
const authRoutes = require('./routes/auth');
const usersRoutes = require('./routes/users');
const siswaRoutes = require('./routes/siswa');
const guruRoutes = require('./routes/guru');
const kelasRoutes = require('./routes/kelas');
const mapelRoutes = require('./routes/mapel');
const nilaiRoutes = require('./routes/nilai');
const presensiRoutes = require('./routes/presensi');
const pengumumanRoutes = require('./routes/pengumuman');
const pembayaranRoutes = require('./routes/pembayaran');
const jadwalRoutes = require('./routes/jadwal');
const dashboardRoutes = require('./routes/dashboard');

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/siswa', siswaRoutes);
app.use('/api/guru', guruRoutes);
app.use('/api/kelas', kelasRoutes);
app.use('/api/mapel', mapelRoutes);
app.use('/api/nilai', nilaiRoutes);
app.use('/api/presensi', presensiRoutes);
app.use('/api/pengumuman', pengumumanRoutes);
app.use('/api/pembayaran', pembayaranRoutes);
app.use('/api/jadwal', jadwalRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Health check
app.get('/', (req, res) => {
  res.json({
    message: 'SIAKAD API Server',
    version: '1.0.0',
    status: 'running'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
});
