const mysql = require('mysql2/promise');

// Pool partagé : il réutilise les connexions et évite d'ouvrir une connexion par requête.
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'arcadia',
  port: Number.parseInt(process.env.DB_PORT, 10) || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
  // Les requêtes préparées réduisent le risque d'injection SQL.
  namedPlaceholders: true
});

module.exports = pool;
