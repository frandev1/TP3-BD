import { Router } from "express";
import { verificarUsuario } from "../controllers/credito.controller";

const router = Router();

router.post('/login', verificarUsuario);

export default router;