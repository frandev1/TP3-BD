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

        -- Seleccionar solo las tarjetas asociadas al tarjetahabiente específico (TH)
        SELECT DISTINCT
            TF.Codigo AS NumeroTarjeta,  -- Código de la tarjeta
            CASE
                WHEN TF.EsActiva = 1 THEN 'Activa'
                WHEN TF.EsActiva = 0 THEN 'Inactiva'
            END AS EstadoCuenta,
            TF.FechaVencimiento,
            CASE 
                WHEN TCA.id IS NOT NULL THEN 'TCA'
                WHEN TCM.id IS NOT NULL THEN 'TCM'
                ELSE NULL
            END AS TipoCuenta,
            TF.FechaCreacion
        FROM 
            [sistemaTarjetaCredito].[dbo].[TF] TF
        INNER JOIN TCA ON TF.id = TCA.id  -- Unir con TCA usando el ID de la tarjeta
        INNER JOIN TCM ON TF.id = TCM.id  -- Unir con TCM usando el ID de la tarjeta
        WHERE 
            (TCA.idTH = @idTH OR TCM.idTH = @idTH)  -- Solo tarjetas asociadas al TH específico
        ORDER BY 
            TF.FechaCreacion DESC;  -- Orden descendente por fecha de creación

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


SELECT * FROM TF
SELECT * FROM TH

DECLARE @ResultCode INT;

EXEC [dbo].[ObtenerTarjetasAsociadasTH]
    @inUsuarioTH = 'jruiz',  -- Reemplaza 'nombre_usuario' con el nombre de usuario que deseas probar
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
        -- Verificar si el usuario es administrador (cambiado para reflejar la nueva estructura de `UA` si aplica)
        IF EXISTS (
            SELECT 1
            FROM UA  -- Asegúrate de que `UA` existe y contiene los nombres de usuario
            WHERE Username = @NombreUsuario
        )
        BEGIN
            -- Selección de tarjetas TCM y TCA unidas con TF y TH según la nueva estructura
            SELECT DISTINCT
                'TCM' AS TipoTarjeta,
                TCM.Codigo AS CodigoTarjeta,
                TF.Codigo AS CodigoTarjetaFisica,
                TH.Nombre AS NombreTarjetahabiente
            FROM TCM
            INNER JOIN TF ON TCM.id = TF.id  -- Asegúrate de que `TF.id` está correctamente relacionado con `TCM.id`
            INNER JOIN TH ON TCM.idTH = TH.id

            UNION ALL

            SELECT DISTINCT
                'TCA' AS TipoTarjeta,
                TCA.Codigo AS CodigoTarjeta,
                TF.Codigo AS CodigoTarjetaFisica,
                TH.Nombre AS NombreTarjetahabiente
            FROM TCA
            INNER JOIN TF ON TCA.id = TF.id  -- Asegúrate de que `TF.id` está correctamente relacionado con `TCA.id`
            INNER JOIN TH ON TCA.idTH = TH.id;

            -- Establecer el código de salida exitoso
            SET @OutResultCode = 0;
        END
        ELSE
        BEGIN
            -- Si no es administrador, establecer código de error
            SET @OutResultCode = 50001;  
            RAISERROR('Usuario no autorizado.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @OutResultCode = ERROR_NUMBER();

        -- Insertar el error en la tabla DBError
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

        -- Lanzar mensaje de error
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
    @OutNombre VARCHAR(64) OUTPUT,
    @OutResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicializar los valores de salida
        SET @OutResultCode = 0;
        SET @OutTipoUsuario = NULL;
        SET @OutNombre = NULL;

        -- Verificar si el nombre de usuario existe en la tabla UA
        IF EXISTS (
            SELECT 1 
            FROM [sistemaTarjetaCredito].[dbo].[UA] UA 
            WHERE UA.Username = @inNombre
        )
        BEGIN
            -- Si el nombre existe, verificar la contraseña
            IF EXISTS (
                SELECT 1 
                FROM [sistemaTarjetaCredito].[dbo].[UA] UA 
                WHERE UA.Username = @inNombre 
                AND UA.Password = @inPassword
            )
            BEGIN
                -- Credenciales correctas para un usuario administrativo
                SET @OutTipoUsuario = 0;
            END
            ELSE
            BEGIN
                -- Contraseña incorrecta para un usuario administrativo
                SET @OutResultCode = 50002; -- Código para contraseña incorrecta
            END
        END
        ELSE IF EXISTS (
            -- Verificar si el nombre de usuario existe en la tabla TH
            SELECT 1 
            FROM [sistemaTarjetaCredito].[dbo].[TH] TH 
            WHERE TH.NombreUsuario = @inNombre
        )
        BEGIN
            -- Si el nombre existe, verificar la contraseña
            IF EXISTS (
                SELECT 1 
                FROM [sistemaTarjetaCredito].[dbo].[TH] TH 
                WHERE TH.NombreUsuario = @inNombre 
                AND TH.Password = @inPassword
            )
            BEGIN
                -- Credenciales correctas para un tarjetahabiente
                SET @OutTipoUsuario = 1;

                -- Devuelve opcionalmente el nombre del usuario
                SELECT @OutNombre = TH.Nombre
                FROM [sistemaTarjetaCredito].[dbo].[TH]
                WHERE TH.NombreUsuario = @inNombre;
            END
            ELSE
            BEGIN
                -- Contraseña incorrecta para un tarjetahabiente
                SET @OutResultCode = 50002; -- Código para contraseña incorrecta
            END
        END
        ELSE
        BEGIN
            -- Usuario no encontrado
            SET @OutResultCode = 50003; -- Código para usuario no encontrado
        END
    END TRY
    BEGIN CATCH
        -- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Asignar el código de error genérico
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
    END CATCH;

    SET NOCOUNT OFF;
END;
GO



--PROBAR SP OBTENER TODAS LAS TARJETAS
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



SELECT * FROM UA

--PROBAR SP VERIFICAR USUARIO
DECLARE @OutTipoUsuario INT;
DECLARE @OutResultCode INT;

EXEC [dbo].[verificarUsuario]
    @inNombre = 'simple',      -- Reemplaza 'nombre_usuario' con el nombre de usuario que deseas probar
    @inPassword = 'simple123',  -- Reemplaza 'password_usuario' con la contraseña que deseas probar
    @OutTipoUsuario = @OutTipoUsuario OUTPUT,
    @OutResultCode = @OutResultCode OUTPUT;

-- Verificar el código de resultado
IF @OutResultCode = 0
BEGIN
    PRINT 'Autenticación exitosa.';
    
    -- Comprobar el tipo de usuario
    IF @OutTipoUsuario = 0
    BEGIN
        PRINT 'Usuario administrativo autenticado.';
    END
    ELSE IF @OutTipoUsuario = 1
    BEGIN
        PRINT 'Tarjetahabiente autenticado.';
    END
    ELSE
    BEGIN
        PRINT 'Tipo de usuario desconocido.';
    END
END
ELSE
BEGIN
    PRINT 'Error en la autenticación.';
END
