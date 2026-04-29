const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// ==========================================
// CORS Configuration untuk Cloudflare Tunnel
// ==========================================
const allowedOrigins = [
  // Development
  'http://localhost:3000',
  'http://localhost:8080',
  'http://127.0.0.1:3000',
  // Cloudflare Tunnel (SIMANIS)
  'https://api.sinan.my.id',
  'https://sinan.my.id',
  // Subdomain tambahan (jika ada)
  'https://www.sinan.my.id',
];

const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc)
    if (!origin) return callback(null, true);

    if (allowedOrigins.indexOf(origin) !== -1 || process.env.NODE_ENV === 'development') {
      callback(null, true);
    } else {
      console.log(`CORS blocked: ${origin}`);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
    'X-Access-Token',
    'X-Refresh-Token'
  ],
  exposedHeaders: ['Authorization', 'X-Access-Token'],
  maxAge: 86400 // 24 hours
};

// ==========================================
// Middleware
// ==========================================
app.use(cors(corsOptions));

// Security Headers untuk Cloudflare Tunnel
app.use((req, res, next) => {
  // HSTS - Force HTTPS
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');
  // XSS Protection
  res.setHeader('X-XSS-Protection', '1; mode=block');
  // Frame options
  res.setHeader('X-Frame-Options', 'DENY');
  // Referrer policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});

app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Request logging untuk debugging
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  const protocol = req.headers['x-forwarded-proto'] || req.protocol;
  console.log(`[${timestamp}] ${req.method} ${req.path} - Protocol: ${protocol}, Origin: ${req.headers.origin || 'none'}`);
  next();
});

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

// ==========================================
// Health Check & Info Endpoints
// ==========================================
app.get('/', (req, res) => {
  res.json({
    message: 'SIMANIS API Server',
    version: '1.0.0',
    status: 'running',
    environment: process.env.NODE_ENV || 'development',
    https: req.headers['x-forwarded-proto'] === 'https',
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint untuk monitoring
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Debug endpoint (hanya development)
app.get('/debug', (req, res) => {
  if (process.env.NODE_ENV === 'production') {
    return res.status(403).json({ error: 'Debug endpoint disabled in production' });
  }
  res.json({
    headers: req.headers,
    protocol: req.protocol,
    secure: req.secure,
    forwardedProto: req.headers['x-forwarded-proto'],
    forwardedHost: req.headers['x-forwarded-host'],
    origin: req.headers.origin,
    remoteAddress: req.connection.remoteAddress
  });
});

// ==========================================
// Error Handling Middleware
// ==========================================
app.use((err, req, res, next) => {
  console.error('Error:', err);

  // CORS errors
  if (err.message === 'Not allowed by CORS') {
    return res.status(403).json({
      success: false,
      message: 'CORS error: Origin not allowed',
      origin: req.headers.origin
    });
  }

  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// ==========================================
// Start Server
// ==========================================
app.listen(PORT, () => {
  console.log(`🚀 SIMANIS Server running on http://localhost:${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 Cloudflare Tunnel: https://api.sinan.my.id`);
  console.log(`🔒 JWT Secret: ${process.env.JWT_SECRET ? 'Configured ✓' : '⚠️ Using default - Update JWT_SECRET in .env!'}`);
  console.log(`
📋 Endpoints:`);
  console.log(`   - API Base: http://localhost:${PORT}/api`);
  console.log(`   - Health:   http://localhost:${PORT}/health`);
  console.log(`   - Debug:    http://localhost:${PORT}/debug (dev only)`);
});
