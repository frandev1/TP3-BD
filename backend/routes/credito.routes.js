import { Router } from "express";
import { tarjetasTH, verificarUsuario } from "../controllers/credito.controller";

const router = Router();

router.post('/login', verificarUsuario);
router.post('/th', tarjetasTH);

export default router;