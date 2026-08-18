const jwt = require('jsonwebtoken');

function verifyToken(req, res, next) {
  const authorization = req.get('Authorization') || '';
  const [scheme, token] = authorization.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Authentification requise.' });
  }
  if (!process.env.JWT_SECRET) {
    console.error('JWT_SECRET n’est pas configuré.');
    return res.status(500).json({ error: 'Configuration serveur invalide.' });
  }

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    return next();
  } catch (error) {
    // Ne pas distinguer token expiré, mal formé ou signé avec une mauvaise clé côté client.
    return res.status(401).json({ error: 'Jeton invalide ou expiré.' });
  }
}

function authorizeRoles(...roles) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ error: 'Authentification requise.' });
    if (!roles.includes(req.user.role)) return res.status(403).json({ error: 'Accès interdit.' });
    return next();
  };
}

module.exports = { verifyToken, authorizeRoles };
