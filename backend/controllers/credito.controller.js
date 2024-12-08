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
            .output('OutNombre', sql.VarChar, null)
            .output('OutResultCode', sql.Int, 0)
            .execute('sistemaTarjetaCredito.dbo.verificarUsuario');

        console.log(result.output.OutResultCode);
        console.log(result.output.OutTipoUsuario);
        console.log(result.output.OutNombre);
        if (result.output.OutResultCode === 0) {
            if (result.output.OutTipoUsuario == 0){
                res.status(200).json({
                    authenticated: true,
                    tipoUsuario: 'UA',
                    msg: 'Inicio de sesión exitoso'
                });
            } else {
                var Nombre = result.output.OutNombre;
                res.status(201).json({
                    authenticated: true,
                    tipoUsuario: 'TH',
                    msg: 'Inicio de sesión exitoso',
                    Nombre: Nombre
                })
            }
        } else {
            if (result.output.OutResultCode === 50002) {
                res.status(400).json({ 
                    authenticated: false, 
                    msg: 'Contraseña incorrecta' 
                });
            }
            else{
                res.status(402).json({
                    authenticated: false,
                    msg: 'Error al iniciar sesión'
                })
            }
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
            .input('inNombreUsuario', sql.VarChar, nombreUsuario)
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


export const getMovimientosPorTarjetaFisica = async (req, res) => {
    const { codigoTarjeta, tipoCuenta, fechaCorte } = req.params;
    console.log("Codigo Tarjeta: ", codigoTarjeta);
    console.log("Tipo Cuenta: ", tipoCuenta);
    console.log("Fecha Corte: ", fechaCorte);

    try {
        // Obtenemos la conexión
        const pool = await getConnection();

        // Ejecutamos el procedimiento almacenado
        const result = await pool
            .request()
            .input("inCodigoTC", sql.VarChar(50), codigoTarjeta) // Parametrizamos el input
            .input("inTipoTC", sql.VarChar(50), tipoCuenta)
            .input("inFechaCorte", sql.Date, fechaCorte)
            .output("OutResultCode", sql.Int, 0)
            .execute("sistemaTarjetaCredito.dbo.ObtenerMovimientos"); // Nombre del SP
        
        console.log(result.recordset);

        const outputResultCode = result.output.OutResultCode;

        if (outputResultCode && outputResultCode !== 0) {
            return res.status(500).json({
                error: "Error al obtener el estado de cuenta",
                resultCode: outputResultCode,
            });
        }
        // Enviamos los resultados
        res.json(result.recordset); // Enviamos solo el recordset al cliente
    } catch (error) {
        console.error("Error al ejecutar el procedimiento almacenado:", error.message);
        res.status(500).json({ error: "Error al obtener movimientos." });
    }
};

export const getEstadoCuenta = async (req, res) => {
    const { codigoTarjeta, tipoCuenta } = req.params;

    console.log("Codigo Tarjeta: ", codigoTarjeta);
    console.log("Tipo Cuenta: ", tipoCuenta);

    try {
        // Obtener conexión a la base de datos
        const pool = await getConnection();

        // Ejecutar el procedimiento almacenado
        const result = await pool
            .request()
            .input("InCodigoTF", sql.VarChar(64), codigoTarjeta)     
            .input("InTipoTF", sql.VarChar(4), tipoCuenta)
            .output("OutResultCode", sql.Int, 0)             
            .execute("sistemaTarjetaCredito.dbo.ObtenerEstadoCuenta");              

        const outputResultCode = result.output.OutResultCode;

        // Validar si hubo errores en el procedimiento almacenado
        if (outputResultCode && outputResultCode !== 0) {
            return res.status(500).json({
                error: "Error al obtener el estado de cuenta",
                resultCode: outputResultCode,
            });
        }
        // Enviar los resultados al cliente
        res.json(result.recordset);
    } catch (error) {
        console.error("Error al ejecutar el SP ObtenerEstadoCuenta:", error.message);
        res.status(500).json({ error: "Error interno del servidor." });
    }
};
