-- Borrar todo el contenido de las tablas
USE [sistemaTarjetaCredito]
GO
-- Desactivar restricciones de claves foráneas
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Eliminar todos los registros de cada tabla
EXEC sp_MSforeachtable 'DELETE FROM ?';

-- Activar nuevamente las restricciones de claves foráneas
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
