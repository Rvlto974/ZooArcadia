const pool = require('../config/db');

// Les colonnes sensibles (password) ne sont jamais renvoyées par les fonctions de lecture.
async function findUserByEmail(email) {
  const [rows] = await pool.execute(
    'SELECT id, email, password, role, created_at FROM users WHERE email = :email LIMIT 1',
    { email }
  );
  return rows[0] || null;
}

async function createUser({ email, password_hash, role = 'employee' }) {
  const [result] = await pool.execute(
    'INSERT INTO users (email, password, role) VALUES (:email, :password, :role)',
    { email, password: password_hash, role }
  );
  return findUserById(result.insertId);
}

async function findUserById(id) {
  const [rows] = await pool.execute(
    'SELECT id, email, role, created_at FROM users WHERE id = :id LIMIT 1',
    { id }
  );
  return rows[0] || null;
}

module.exports = { findUserByEmail, createUser, findUserById };
