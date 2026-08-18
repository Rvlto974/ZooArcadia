# Module d’authentification — Zoo Arcadia

Module Express/MySQL prêt à intégrer dans le backend existant. Les commentaires du code sont en français. Il utilise un pool `mysql2/promise`, `bcrypt` pour les mots de passe et des JWT valables 8 heures.

## Installation et configuration

1. Depuis le dossier `backend`, vérifiez les dépendances :
   ```bash
   npm install express mysql2 cors dotenv bcrypt jsonwebtoken
   ```
2. Créez la base puis exécutez le script SQL :
   ```bash
   mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS arcadia CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   mysql -u root -p arcadia < ../users.sql
   ```
3. Dans `.env`, définissez au minimum `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` et `JWT_SECRET`. `DB_PORT` est facultatif et vaut `3306` par défaut. En production, utilisez une valeur aléatoire forte pour `JWT_SECRET`.
4. Remplacez les fichiers correspondants dans votre backend et démarrez :
   ```bash
   node server.js
   # ou npm run dev si le script nodemon est configuré
   ```

## Inscription

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"employe@zoo-arcadia.fr","password":"MotDePasseFort123!"}'
```

Réponse `201` :
```json
{"message":"Compte créé avec succès.","user":{"id":1,"email":"employe@zoo-arcadia.fr","role":"employee","created_at":"2026-08-18T..."}}
```

L’inscription publique crée toujours un rôle `employee`; elle n’accepte pas de rôle fourni par le client pour éviter une élévation de privilèges.

## Connexion

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"employe@zoo-arcadia.fr","password":"MotDePasseFort123!"}'
```

Réponse `200` :
```json
{"message":"Connexion réussie.","token":"<JWT>","expiresIn":"8h","user":{"id":1,"email":"employe@zoo-arcadia.fr","role":"employee","created_at":"2026-08-18T..."}}
```

Pour une route protégée, transmettre :
```http
Authorization: Bearer <JWT>
```
Puis utiliser `verifyToken` et, si nécessaire, `authorizeRoles('admin')` dans la route.

## Erreurs attendues

- `400` : email invalide, mot de passe absent ou trop court (8 à 72 caractères).
- `401` : identifiants incorrects, en-tête Bearer manquant ou JWT invalide/expiré.
- `403` : JWT valide mais rôle insuffisant.
- `409` : adresse email déjà utilisée.
- `500` : erreur interne ou configuration serveur invalide; les détails sensibles ne sont pas envoyés au client.

Les réponses ne contiennent jamais le hash du mot de passe.
