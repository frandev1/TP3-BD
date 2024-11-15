import { getConnection } from "../database/connection";
import sql from 'mssql';

export const verificarUsuario = async (req, res) => {
    const { nombre, password } = req.body;
    console.log('Datos recibidos:', nombre, password); // Verifica los datos recibidos
    try {
        const pool = await getConnection();
        const result = await pool.request()
            .input('inNombre', sql.VarChar, nombre)
            .input('inPassword', sql.VarChar, password)
            .output('OutTipoUsuario', sql.VarChar, null)
            .output('OutResultCode', sql.Int, 0)
            .execute('sistemaTarjetaCredito.dbo.verificarUsuario');

        console.log(result.output.OutResultCode)
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

export const tarjetasTH = async (req, res) => {
    const {usuarioTH} = req.body;
    console.log(usuarioTH);
    try{
        const pool = await getConnection();
        const result = await pool.request()
        .input('inUsuarioTH', sql.VarChar, usuarioTH)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaTarjetaCredito.dbo.ObtenerTarjetasAsociadasTH')

        console.log(result);
        if (result.output.OutResultCode === 0){
            res.status(200).json(result)
        } else{
            res.status(400).json({msg: 'Error al obtener las tarjetas de crédito'})
        }
    } catch(error) {
        console.error('Error al obtener empleados:', error);
        res.status(500).json({ error: 'Error en el servidor' });
    }
}

// Controlador para obtener todas las tarjetas asociadas a un usuario administrador (UA)
export const obtenerTodasLasTarjetas = async (req, res) => {
    const { nombreUsuario } = req.body;
    try {
        const pool = await getConnection();
        const result = await pool.request()
            .input('NombreUsuario', sql.VarChar, nombreUsuario)
            .output('OutResultCode', sql.Int, 0)
            .execute('sistemaTarjetaCredito.dbo.ObtenerTodasLasTarjetas');

        // Revisar el código de resultado
        if (result.output.OutResultCode === 0) {
            res.status(200).json(result.recordset); // Enviar las tarjetas obtenidas al frontend
        } else {
            res.status(400).json({ msg: 'Error al obtener las tarjetas de crédito' });
        }
    } catch (error) {
        console.error('Error al obtener las tarjetas:', error);
        res.status(500).json({ error: 'Error en el servidor' });
    }
};