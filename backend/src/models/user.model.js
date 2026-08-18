const pool = require('../config/db');

// Le mot de passe (mot_de_passe) ne doit jamais être renvoyé en dehors de findUserByEmail (utilisé uniquement pour vérifier le login).
async function findUserByEmail(email) {
  const [rows] = await pool.execute(
    'SELECT id, nom, prenom, email, mot_de_passe, role, created_at FROM utilisateurs WHERE email = :email LIMIT 1',
    { email }
  );
  return rows[0] || null;
}

async function createUser({ nom, prenom, email, password_hash, role = 'employe' }) {
  const [result] = await pool.execute(
    'INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, role) VALUES (:nom, :prenom, :email, :mot_de_passe, :role)',
    { nom, prenom, email, mot_de_passe: password_hash, role }
  );
  return findUserById(result.insertId);
}

async function findUserById(id) {
  const [rows] = await pool.execute(
    'SELECT id, nom, prenom, email, role, created_at FROM utilisateurs WHERE id = :id LIMIT 1',
    { id }
  );
  return rows[0] || null;
}

module.exports = { findUserByEmail, createUser, findUserById };