USE [sistemaTarjetaCredito]
GO

CREATE PROCEDURE verificarUsuario (
    @nombre NVARCHAR(50),
    @password NVARCHAR(50)
)
AS
BEGIN
    IF EXISTS (SELECT 1 
	FROM UA 
	WHERE Nombre = @nombre 
	AND Password = @password)
    
	BEGIN
        SELECT 'Autenticado' AS Resultado;
    END
    ELSE
    BEGIN
        SELECT 'No autenticado' AS Resultado;
    END
END;


