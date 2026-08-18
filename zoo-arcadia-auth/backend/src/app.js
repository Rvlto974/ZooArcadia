const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth.routes');

const app = express();

app.use(cors());
app.use(express.json({ limit: '10kb' }));

app.get('/', (req, res) => res.json({ message: 'Zoo Arcadia API opérationnelle.' }));
app.use('/api/auth', authRoutes);

app.use((req, res) => res.status(404).json({ error: 'Route introuvable.' }));
app.use((error, req, res, next) => {
  console.error('Erreur non gérée :', error);
  return res.status(500).json({ error: 'Erreur interne du serveur.' });
});

module.exports = app;
