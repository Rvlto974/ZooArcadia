// dotenv doit être chargé avant l'import de l'application et de ses modules.
require('dotenv').config({ path: require('path').resolve(__dirname, '../../backend/.env') });

const app = require('./src/app');

const PORT = Number.parseInt(process.env.PORT, 10) || 5000;
app.listen(PORT, () => console.log(`Zoo Arcadia API démarrée sur le port ${PORT}.`));
