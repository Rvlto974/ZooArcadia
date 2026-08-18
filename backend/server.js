const app = require('./src/app');
require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`✅ Serveur démarré sur http://localhost:${PORT}`);
});