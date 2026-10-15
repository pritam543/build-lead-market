const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// MySQL Connection Pool (Optimized for TiDB Cloud & Render with Connection Timeout)
const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 4000,
    ssl: {
        minVersion: 'TLSv1.2',
        rejectUnauthorized: true
    },
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    connectTimeout: 30000 // 30 seconds timeout to prevent ETIMEDOUT
});

// Test Database Connection
db.getConnection((err, connection) => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('MySQL / TiDB Connected Successfully!');
    connection.release();
});

// 1. Signup / Login API (Persistent User Save)
app.post('/api/users', (req, res) => {
    const { uid, name, phone, email, firm_name, role } = req.body;
    const query = `INSERT INTO users (uid, name, phone, email, firm_name, role) 
                   VALUES (?, ?, ?, ?, ?, ?) 
                   ON DUPLICATE KEY UPDATE name=?, phone=?, email=?, firm_name=?, role=?`;

    db.query(query, [uid, name, phone, email, firm_name, role, name, phone, email, firm_name, role], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'User saved permanently', success: true });
    });
});

// 2. Get All Leads (Marketplace)
app.get('/api/leads', (req, res) => {
    const query = `SELECT id, client_name, project_name, area, location, budget, category, created_at FROM leads ORDER BY id DESC`;
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 3. Post New Lead API (Client Project Posting)
app.post('/api/leads', (req, res) => {
    const { project_name, location, area, budget, category, client_name, phone, email } = req.body;

    const query = `INSERT INTO leads (project_name, location, area, budget, category, client_name, phone, email, created_at) 
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`;

    db.query(query, [project_name, location, area, budget, category, client_name, phone, email], (err, result) => {
        if (err) {
            console.error('Error inserting lead:', err);
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json({ success: true, message: 'Lead posted permanently', leadId: result.insertId });
    });
});

// 4. Purchase Lead API (Contractor UTR Payment Save)
app.post('/api/purchase', (req, res) => {
    const { lead_id, contractor_uid, contractor_name, contractor_phone, utr_number, amount_paid } = req.body;
    const query = `INSERT INTO purchases (lead_id, contractor_uid, contractor_name, contractor_phone, utr_number, amount_paid) 
                   VALUES (?, ?, ?, ?, ?, ?)`;

    db.query(query, [lead_id, contractor_uid, contractor_name, contractor_phone, utr_number, amount_paid], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Lead purchase saved permanently', success: true });
    });
});

// 5. Get Unlocked Leads for Contractor
app.get('/api/unlocked-leads', (req, res) => {
    const contractorUid = req.query.uid;
    const query = `SELECT l.* FROM leads l JOIN purchases p ON l.id = p.lead_id WHERE p.contractor_uid = ? ORDER BY p.id DESC`;

    db.query(query, [contractorUid], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 6. Admin Master Data APIs
app.get('/api/admin/leads', (req, res) => {
    db.query('SELECT * FROM leads ORDER BY id DESC', (err, results) => res.json(results));
});

app.get('/api/admin/users', (req, res) => {
    db.query('SELECT * FROM users ORDER BY id DESC', (err, results) => res.json(results));
});

app.get('/api/admin/purchases', (req, res) => {
    db.query(`SELECT p.*, l.client_name, l.project_name, l.phone as client_phone 
              FROM purchases p JOIN leads l ON p.lead_id = l.id ORDER BY p.id DESC`, (err, results) => res.json(results));
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});