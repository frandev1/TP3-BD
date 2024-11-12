USE [sistemaTarjetaCredito]
GO

/****** Object:  StoredProcedure [dbo].[verificarUsuario]    Script Date: 11/11/2024 15:34:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[verificarUsuario] (
    @nombre VARCHAR(50),
    @password VARCHAR(50),
    @OutTipoUsuario INT OUTPUT,
    @OutResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicializar el código de resultado y el tipo de usuario
        SET @OutResultCode = 0;

        -- Verificar en la tabla de usuarios administrativos (UA)
        IF EXISTS (
            SELECT 1 
            FROM UA 
            WHERE Nombre = @nombre 
            AND Password = @password
        )
        BEGIN
            -- Autenticación exitosa como usuario adiministrativo (UA)
            SET @OutTipoUsuario = 0;
        END
        ELSE IF EXISTS (
            -- Verificar en la tabla de tarjetahabientes (TH)
            SELECT 1 
            FROM TH 
            WHERE NombreUsuario = @nombre 
            AND Password = @password
        )
        BEGIN
            -- Autenticación exitosa como tarjetahabiente (TH)
            SET @OutTipoUsuario = 1;
        END
        ELSE
        BEGIN
            -- Autenticación fallida
            SET @OutResultCode = 50001
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

        -- Registrar el error en la tabla DBError
        INSERT INTO [sistemaTarjetaCredito].[dbo].[DBError]
        (
        ErrorUsername,
        ErrorNumber,
        ErrorState,
        ErrorSeverity,
        ErrorLine,
        ErrorProcedure,
        ErrorMessage,
        ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
    END CATCH

    SET NOCOUNT OFF;
END;
