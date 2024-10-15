import sql from 'mssql';
import config from '../src/config';

const dbConfig = {
    user: config.user,
    password: config.password,
    server: config.server,
    database: config.database,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

export async function getConnection() {
    try {
        const pool = await sql.connect(dbConfig);
        return pool;
    } catch (error) {
        console.error(error);
    }
}