const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded images
app.use('/uploads', express.static('uploads'));

// Database configuration
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'userdb',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
});

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Initialize database table
async function initializeDatabase() {
  try {
    const client = await pool.connect();
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        age INTEGER NOT NULL,
        image_path VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    client.release();
    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Database initialization error:', err);
  }
}

// Routes
app.get('/api/users', async (req, res) => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT * FROM users ORDER BY created_at DESC');
    client.release();
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching users:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/users', upload.single('image'), async (req, res) => {
  try {
    const { name, age } = req.body;
    const imagePath = req.file ? `/uploads/${req.file.filename}` : null;

    if (!name || !age || !imagePath) {
      return res.status(400).json({ error: 'Name, age, and image are required' });
    }

    const client = await pool.connect();
    const result = await client.query(
      'INSERT INTO users (name, age, image_path) VALUES ($1, $2, $3) RETURNING *',
      [name, parseInt(age), imagePath]
    );
    client.release();

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating user:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.delete('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const client = await pool.connect();
    
    // Get the image path before deleting
    const userResult = await client.query('SELECT image_path FROM users WHERE id = $1', [id]);
    
    if (userResult.rows.length === 0) {
      client.release();
      return res.status(404).json({ error: 'User not found' });
    }

    // Delete the user
    await client.query('DELETE FROM users WHERE id = $1', [id]);
    client.release();

    // Delete the image file
    const imagePath = path.join(__dirname, userResult.rows[0].image_path);
    if (fs.existsSync(imagePath)) {
      fs.unlinkSync(imagePath);
    }

    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    console.error('Error deleting user:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Initialize database and start server
initializeDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}); 