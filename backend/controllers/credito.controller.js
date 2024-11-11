import { getConnection } from "../database/connection";
import sql from 'mssql';

export const verificarUsuario = async (req, res) => {
    const { nombre, password } = req.body;
    console.log('Datos recibidos:', nombre, password); // Verifica los datos recibidos
    try {
        const pool = await getConnection();
        const result = await pool.request()
            .input('nombre', sql.VarChar, nombre)
            .input('password', sql.VarChar, password)
            .execute('verificarUsuario');

        const { Resultado } = result.recordset[0];

        if (Resultado === 'Autenticado') {
            res.json({ authenticated: true });
        } else {
            res.json({ authenticated: false });
        }
    } catch (error) {
        console.error('Error en la autenticación:', error);
        res.status(500).json({ error: 'Error en el servidor' });
    }
};