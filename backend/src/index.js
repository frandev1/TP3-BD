import app from "./app"
import '../database/connection'
import { getConnection } from '../database/connection.js'; 
import express from 'express';
import {creditoRoutes} from '../routes/credito.routes.js';





async function verificarConexionBD() {
    const pool = await getConnection();
    if (pool) {
        console.log('Conexión establecida con la BASE DE DATOS.');
    } else {
        console.log('No se pudo establecer la conexión a la base de datos.');
    }
}

verificarConexionBD();


app.listen(app.get('port'));
console.log('Server on port', app.get('port'));



