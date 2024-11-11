USE [sistemaTarjetaCredito]
GO

ALTER PROCEDURE verificarUsuario (
    @nombre VARCHAR(50),
    @password VARCHAR(50),
    @OutTipoUsuario VARCHAR(2) OUTPUT,
    @OutResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicializar el código de resultado y el tipo de usuario
        SET @OutResultCode = 0;
        SET @OutTipoUsuario = NULL;

        -- Verificar en la tabla de usuarios administrativos (UA)
        IF EXISTS (
            SELECT 1 
            FROM UA 
            WHERE Nombre = @nombre 
            AND Password = @password
        )
        BEGIN
            -- Autenticación exitosa como usuario adiministrativo (UA)
            SET @OutTipoUsuario = 'UA';
        END
        ELSE IF EXISTS (
            -- Verificar en la tabla de tarjetahabientes (TH)
            SELECT 1 
            FROM TH 
            WHERE Nombre = @nombre 
            AND Password = @password
        )
        BEGIN
            -- Autenticación exitosa como tarjetahabiente (TH)
            SET @OutTipoUsuario = 'TH';
        END
        ELSE
        BEGIN
            -- Autenticación fallida
            SET @OutResultCode = 50001
            SET @OutTipoUsuario = NULL;
        END
    END TRY
    BEGIN CATCH
    -- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
        END;
        -- Asignar el código de error de la base de datos al resultado de salida
        SET @OutResultCode = 50008;
    END CATCH

    SET NOCOUNT OFF;
END;

