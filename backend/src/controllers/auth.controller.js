const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userModel = require('../models/user.model');

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PASSWORD_MIN_LENGTH = 8;

function publicUser(user) {
  return { id: user.id, nom: user.nom, prenom: user.prenom, email: user.email, role: user.role, created_at: user.created_at };
}

function signToken(user) {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET_MISSING');
  }
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '8h', subject: String(user.id) }
  );
}

async function register(req, res) {
  const email = typeof req.body?.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';
  const nom = typeof req.body?.nom === 'string' ? req.body.nom.trim() : '';
  const prenom = typeof req.body?.prenom === 'string' ? req.body.prenom.trim() : '';

  if (!EMAIL_PATTERN.test(email) || email.length > 254) {
    return res.status(400).json({ error: 'Adresse email invalide.' });
  }
  if (password.length < PASSWORD_MIN_LENGTH || password.length > 72) {
    return res.status(400).json({ error: `Le mot de passe doit contenir entre ${PASSWORD_MIN_LENGTH} et 72 caractères.` });
  }
  if (!nom || !prenom) {
    return res.status(400).json({ error: 'Nom et prénom requis.' });
  }

  try {
    const existingUser = await userModel.findUserByEmail(email);
    if (existingUser) return res.status(409).json({ error: 'Un compte existe déjà avec cette adresse email.' });

    // L'inscription publique crée toujours un employé : seul un flux administrateur peut créer un admin ou un vétérinaire.
    const password_hash = await bcrypt.hash(password, 12);
    const user = await userModel.createUser({ nom, prenom, email, password_hash, role: 'employe' });
    return res.status(201).json({ message: 'Compte créé avec succès.', user: publicUser(user) });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'Un compte existe déjà avec cette adresse email.' });
    console.error('Erreur lors de la création du compte :', error);
    return res.status(500).json({ error: 'Erreur interne du serveur.' });
  }
}

async function login(req, res) {
  const email = typeof req.body?.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';

  if (!email || !password) return res.status(400).json({ error: 'Email et mot de passe requis.' });

  try {
    const user = await userModel.findUserByEmail(email);
    if (!user || !(await bcrypt.compare(password, user.mot_de_passe))) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect.' });
    }
    const token = signToken(user);
    return res.status(200).json({ message: 'Connexion réussie.', token, expiresIn: '8h', user: publicUser(user) });
  } catch (error) {
    if (error.message === 'JWT_SECRET_MISSING') {
      console.error('JWT_SECRET n\u2019est pas configuré.');
      return res.status(500).json({ error: 'Configuration serveur invalide.' });
    }
    console.error('Erreur lors de la connexion :', error);
    return res.status(500).json({ error: 'Erreur interne du serveur.' });
  }
}

module.exports = { register, login };