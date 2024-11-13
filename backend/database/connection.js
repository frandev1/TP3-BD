import sql from 'mssql';
import config from '../src/config';

const dbSetting = {
    user: config.user,
    password: config.password,
    server: config.server,
    database: config.database,
    authentication: {
        type: 'default' // o 'default' si ntlm no funciona
    },
    options: {
        trustedConnection: true,
        encrypt: true,
        trustServerCertificate: true
    }
};


export async function getConnection() {
    try {
        const pool = await sql.connect(dbSetting);
        return pool;
    } catch (error) {
        console.error('Error en la conexión a la base de datos:', error);
        return null;
    }
}


