import { Router } from "express";
import { tarjetasTH, verificarUsuario, obtenerTodasLasTarjetas } from "../controllers/credito.controller";

const router = Router();

router.post('/login', verificarUsuario);
router.post('/th', tarjetasTH);

// Ruta para obtener todas las tarjetas para un usuario administrador
router.post('/tarjetasUA', obtenerTodasLasTarjetas);

export default router;