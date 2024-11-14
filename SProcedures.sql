USE [sistemaTarjetaCredito]
GO

/****** Object:  StoredProcedure [dbo].[ObtenerTarjetasAsociadasTH]    Script Date: 13/11/2024 16:28:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerTarjetasAsociadasTH]
    @inUsuarioTH VARCHAR(32),  -- Nombre de usuario de la TH
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Se inicializa la variable de salida
        SET @OutResultCode = 0;

        DECLARE @idTH INT;

        -- Obtener el id del tarjetahabiente
        SELECT @idTH = id
        FROM [sistemaTarjetaCredito].[dbo].[TH]
        WHERE NombreUsuario = @inUsuarioTH;

        -- Verificar que el id se obtuvo correctamente
        IF @idTH IS NULL
        BEGIN
            SET @OutResultCode = 50002;  -- Código de error para usuario no encontrado
            RAISERROR('Usuario no encontrado.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION

        -- Seleccionar las tarjetas asociadas al tarjetahabiente con el tipo de cuenta
        SELECT DISTINCT
            TF.Numero AS NumeroTarjeta,
            CASE
                WHEN TF.EsActiva = 1 THEN 'Activa'
                WHEN TF.EsActiva = 0 THEN 'Inactiva'
            END AS EstadoCuenta,
            TF.FechaVencimiento,
            CASE 
                WHEN TCA.id IS NOT NULL THEN 'TCA'
                WHEN TCM.id IS NOT NULL THEN 'TCM'
                ELSE NULL
            END AS TipoCuenta
        FROM 
            [sistemaTarjetaCredito].[dbo].[TF] TF
        LEFT JOIN TCA ON TF.idTCM = TCA.id  -- Relación con TCA
        LEFT JOIN TCM ON TF.idTCM = TCM.id  -- Relación con TCM
        INNER JOIN TH ON TH.id = TF.idTH
        WHERE 
            TH.id = @idTH  -- Solo tarjetas asociadas al Tarjetahabiente
        ORDER BY 
            TF.FechaCreacion DESC;  -- Orden descendente por fecha de vencimiento

        COMMIT TRANSACTION
        
    END TRY
    BEGIN CATCH
        -- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        
        -- Asignar el código de error de la base de datos al resultado de salida
        SET @OutResultCode = ERROR_NUMBER();

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
            ErrorDateTime
        )
        VALUES
        (
            SUSER_NAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

    SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ObtenerTodasLasTarjetas]    Script Date: 13/11/2024 16:28:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerTodasLasTarjetas]
    @NombreUsuario VARCHAR(50),
    @OutResultCode INT OUTPUT  
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- ES ADMIN
        IF EXISTS (
            SELECT 1
            FROM UA
            WHERE Nombre = @NombreUsuario
        )
        BEGIN
            -- TCM TCA UNION CON TF
            SELECT DISTINCT
                'TCM' AS TipoTarjeta,
                TCM.Codigo,
                TF.Numero,
                TH.Nombre AS NombreTarjetahabiente
            FROM TCM
            INNER JOIN TF ON TCM.id = TF.idTCM  
            INNER JOIN TH ON TCM.idTH = TH.id

            UNION ALL

            SELECT DISTINCT
                'TCA' AS TipoTarjeta,
                TCA.Codigo,
                TF.Numero,
                TH.Nombre AS NombreTarjetahabiente
            FROM TCA
            INNER JOIN TF ON TCA.id = TF.idTCM  
            INNER JOIN TH ON TCA.idTH = TH.id;

            SET @OutResultCode = 0;  -- CORONO
        END
        ELSE
        BEGIN
            -- NO ADMIN
            SET @OutResultCode = 50001;  
            RAISERROR('Usuario no autorizado.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        -- ERRORES
        SET @OutResultCode = ERROR_NUMBER();

        -- DBERROR
        INSERT INTO [dbo].[DBError] (
            ErrorUserName,
            ErrorNumber,
            ErrorState,
            ErrorSeverity,
            ErrorLine,
            ErrorProcedure,
            ErrorMessage,
            ErrorDateTime
        )
        VALUES (
            SUSER_NAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );

        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[verificarUsuario]    Script Date: 13/11/2024 16:28:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[verificarUsuario] (
    @inNombre VARCHAR(50),
    @inPassword VARCHAR(50),
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
            FROM [sistemaTarjetaCredito].[dbo].[UA] UA 
            WHERE UA.Nombre = @inNombre 
            AND UA.Password = @inPassword
        )
        BEGIN
            -- Autenticación exitosa como usuario adiministrativo (UA)
            SET @OutTipoUsuario = 0;
        END
        ELSE IF EXISTS (
            -- Verificar en la tabla de tarjetahabientes (TH)
            SELECT 1 
            FROM [sistemaTarjetaCredito].[dbo].[TH] TH 
            WHERE TH.NombreUsuario = @inNombre 
            AND TH.Password = @inPassword
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
GO


--PROBAR SP
DECLARE @ResultCode INT;

EXEC ObtenerTodasLasTarjetas
    @NombreUsuario = 'simple',  -- Reemplaza con el nombre de usuario del administrador
    @OutResultCode = @ResultCode OUTPUT;

-- Verificar el código de resultado
IF @ResultCode = 0
BEGIN
    PRINT 'Datos obtenidos exitosamente.';
END
ELSE
BEGIN
    PRINT 'Error al obtener los datos.';
END

