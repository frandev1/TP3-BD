import express from 'express';
import config from './config';
import creditoRoutes from '../routes/credito.routes';

const cors = require('cors');
const app = express();

//settings
app.set('port', config.port);

//middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({extended: false}));

app.use('/api',creditoRoutes)

export default app;