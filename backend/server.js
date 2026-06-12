const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const path = require('path');

require('dotenv').config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Configure Postgres connection via environment variables or defaults
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || undefined,
  user: process.env.PGUSER || 'postgres',
  host: process.env.PGHOST || 'localhost',
  database: process.env.PGDATABASE || 'Concours_Database_Players',
  password: process.env.PGPASSWORD || 'Prince',
  port: process.env.PGPORT ? parseInt(process.env.PGPORT) : 5432,
});

// ---------- CRUD API ----------

// GET /players with filters (id, q, gender, health_status, medical_clearance)
app.get('/players', async (req, res) => {
  try {
    // debug log incoming query for troubleshooting
    console.log('GET /players called with query:', req.query);

    const { id, q, gender, health_status, medical_clearance } = req.query;
    if (id) {
      const r = await pool.query('SELECT * FROM players WHERE player_id = $1', [parseInt(id, 10)]);
      return res.json(r.rows);
    }
    const conditions = [];
    const params = [];
    let idx = 1;
    if (q) { conditions.push(`LOWER(name) LIKE LOWER($${idx++})`); params.push(`%${q}%`); }
    if (gender) { conditions.push(`gender = $${idx++}`); params.push(gender); }
    if (health_status) { conditions.push(`health_status = $${idx++}`); params.push(health_status); }
    if (medical_clearance !== undefined && medical_clearance !== null && medical_clearance !== '') {
      const mc = (medical_clearance === 'true');
      conditions.push(`medical_clearance = $${idx++}`);
      params.push(mc);
    }
    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';
    const sql = `SELECT * FROM players ${where} ORDER BY player_id LIMIT 1000`;
    const r = await pool.query(sql, params);
    return res.json(r.rows);
  } catch (err) {
    console.error('GET /players error', err && (err.stack || err.message || err));
    return res.status(500).json({ error: 'Server error', detail: String(err && err.message) });
  }
});

// POST /players
app.post('/players', async (req, res) => {
  try {
    const { Player_ID, Name, Date_of_Birth, Gender, Health_Status, Medical_Clearance } = req.body;
    if (!Player_ID || !Name || !Date_of_Birth || !Gender || Health_Status == null || Medical_Clearance == null) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const q = `
      INSERT INTO Players (Player_ID, Name, Date_of_Birth, Gender, Health_Status, Medical_Clearance)
      VALUES ($1,$2,$3,$4,$5,$6)
      RETURNING *`;
    const values = [Player_ID, Name, Date_of_Birth, Gender, Health_Status, Medical_Clearance];
    const r = await pool.query(q, values);
    res.status(201).json(r.rows[0]);
  } catch (err) {
    console.error(err);
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Player_ID already exists' });
    }
    res.status(500).json({ error: 'Server error' });
  }
});

// PUT /players/:id
app.put('/players/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (Number.isNaN(id)) return res.status(400).json({ error: 'Invalid player id' });

  const allowed = {
    Name: 'name',
    Date_of_Birth: 'date_of_birth',
    Gender: 'gender',
    Health_Status: 'health_status',
    Medical_Clearance: 'medical_clearance'
  };

  try {
    const keys = Object.keys(req.body).filter(k => Object.keys(allowed).includes(k));
    if (keys.length === 0) return res.status(400).json({ error: 'No valid fields to update' });

    if (req.body.Gender && !['M','F','O'].includes(req.body.Gender)) {
      return res.status(400).json({ error: "Gender must be one of 'M','F','O'" });
    }
    if (req.body.Date_of_Birth) {
      const d = new Date(req.body.Date_of_Birth);
      if (isNaN(d.getTime())) return res.status(400).json({ error: 'Invalid Date_of_Birth format' });
    }
    if (req.body.Medical_Clearance !== undefined && typeof req.body.Medical_Clearance !== 'boolean') {
      return res.status(400).json({ error: 'Medical_Clearance must be boolean true/false' });
    }

    const sets = keys.map((k, idx) => `\"${allowed[k]}\" = $${idx + 1}`);
    const values = keys.map(k => {
      if (k === 'Medical_Clearance') return req.body[k];
      return req.body[k];
    });

    const idParamIndex = values.length + 1;
    const sql = `UPDATE players SET ${sets.join(', ')} WHERE player_id = $${idParamIndex} RETURNING *`;
    values.push(id);

    const result = await pool.query(sql, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }

    return res.json({ updated: result.rows[0] });
  } catch (err) {
    console.error('PUT /players/:id error ->', err && (err.stack || err.message || err));
    if (err.code) {
      return res.status(500).json({
        error: 'Database error',
        code: err.code,
        detail: err.detail || err.message
      });
    }
    return res.status(500).json({ error: 'Server error', detail: String(err && err.message) });
  }
});

// DELETE /players/:id
app.delete('/players/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const r = await pool.query('DELETE FROM Players WHERE Player_ID = $1 RETURNING *', [id]);
    if (r.rows.length === 0) return res.status(404).json({ error: 'Player not found' });
    res.json({ deleted: r.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /players/:id/stats
app.get('/players/:id/stats', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) return res.status(400).json({ error: 'Invalid player id' });

    const playerCheck = await pool.query('SELECT player_id, name FROM players WHERE player_id = $1', [id]);
    if (playerCheck.rows.length === 0) return res.status(404).json({ error: 'Player not found' });
    const player = playerCheck.rows[0];

    const statsQ = await pool.query('SELECT * FROM Get_Player_Stats($1)', [id]);
    const stats = statsQ.rows[0] || { total_matches: 0, total_wins: 0, total_losses: 0 };

    res.json({
      player: { player_id: player.player_id, name: player.name },
      stats: {
        total_matches: parseInt(stats.total_matches, 10) || 0,
        total_wins: parseInt(stats.total_wins, 10) || 0,
        total_losses: parseInt(stats.total_losses, 10) || 0
      }
    });
  } catch (err) {
    console.error('GET /players/:id/stats error', err && (err.stack || err.message || err));
    res.status(500).json({ error: 'Server error', detail: String(err && err.message) });
  }
});

// serve frontend build in production if exists
app.use(express.static(path.join(__dirname, '..', 'frontend', 'build')));
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'frontend', 'build', 'index.html'));
});

// health check
app.get('/', (req, res) => res.send('Players API is running'));

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
