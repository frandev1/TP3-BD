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
            .output('OutTipoUsuario', sql.VarChar, '')
            .output('OutResultCode', sql.Int, 0)
            .execute('sistemaTarjetaCredito.dbo.verificarUsuario');

        console.log(result.output.OutTipoUsuario);
        if (result.output.OutResultCode === 0) {
            if (result.output.OutTipoUsuario == 0){
                res.json({
                    authenticated: true,
                    tipoUsuario: 'UA'
                });
            } else {
                res.json({
                    authenticated: true,
                    tipoUsuario: 'TH'
                })
            }
        } else {
            res.json({ authenticated: false });
        }
    } catch (error) {
        console.error('Error en la autenticación:', error);
        res.status(500).json({ error: 'Error en el servidor' });
    }
};