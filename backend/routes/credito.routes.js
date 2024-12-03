import { Router } from "express";
import { tarjetasTH, verificarUsuario, obtenerTodasLasTarjetas, getMovimientosPorTarjetaFisica, getEstadoCuenta } from "../controllers/credito.controller";

const router = Router();

router.post('/login', verificarUsuario);
router.post('/th', tarjetasTH);

// Ruta para obtener todas las tarjetas para un usuario administrador
router.post('/tarjetasUA', obtenerTodasLasTarjetas);

// Ruta para obtener movimientos de una tarjeta física
router.get('/movimientos/:codigoTarjeta/:tipoCuenta/:fechaCorte', getMovimientosPorTarjetaFisica);

// Ruta para obtener el estado de cuenta
router.get('/estadoCuenta/:codigoTarjeta/:tipoCuenta', getEstadoCuenta);

export default router;