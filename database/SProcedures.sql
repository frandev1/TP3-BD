/****** Object:  StoredProcedure [dbo].[ObtenerEstadoCuenta]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ObtenerEstadoCuenta]
    @InCodigoTF VARCHAR(64),
    @InTipoTF VARCHAR(4),
    @OutResultCode INT OUTPUT
AS
BEGIN
    BEGIN TRY

    DECLARE @idTC INT;

    BEGIN TRANSACTION

    SET @OutResultCode = 0;

    IF (@InTipoTF = 'TCM')
    BEGIN 

        SELECT
            @idTC = TCM.id
        FROM TCM
        INNER JOIN TF ON TF.Codigo = @InCodigoTF
        WHERE TCM.Codigo = TF.CodigoTC;

        SELECT
            EC.FechaCorte,
            EC.PagoMinimo,
            EC.PagoContratado,
            EC.InteresesCorrientes,
            EC.InteresesMoratorios,
            EC.CantidadOperacionesATM,
            EC.CantidadOperacionesVentanilla
        FROM EstadoCuenta EC
        WHERE EC.idTCM = @idTC
        ORDER BY EC.FechaCorte DESC;
    END
    
    IF (@InTipoTF = 'TCA')
    BEGIN

        SELECT
            @idTC = TCA.id
        FROM TCA
        INNER JOIN TF ON TF.Codigo = @InCodigoTF
        WHERE TCA.Codigo = TF.CodigoTC;
        
        SELECT
            SEC.FechaCorte,
            SEC.CantidadOperacionesATM,
            SEC.CantidadOperacionesVentanilla,
            SEC.CantidadCompras,
            SEC.SumaCompras,
            SEC.CantidadRetiros,
            SEC.CantidadRetiros
        FROM SubEstadoCuenta SEC
        INNER JOIN TF ON TF.Codigo = @InCodigoTF
        WHERE SEC.idTCA = @idTC
        ORDER BY SEC.FechaCorte DESC;
    END

    COMMIT TRANSACTION

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
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ObtenerTarjetasAsociadasTH]    Script Date: 20/11/2024 01:23:28 ******/
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
        DECLARE @idUsuario INT;

        -- Obtener el id del tarjetahabiente
        SELECT @idTH = TH.id
        FROM [sistemaTarjetaCredito].[dbo].[TH] TH
        WHERE NombreUsuario = @inUsuarioTH;

        -- Verificar que el id se obtuvo correctamente
        IF @idTH IS NULL
        BEGIN
            SET @OutResultCode = 50002;  -- Código de error para usuario no encontrado
            RAISERROR('Usuario no encontrado.', 16, 1);
            RETURN;
        END

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
        LEFT JOIN TCA TCA ON TF.CodigoTC = TCA.Codigo AND TCA.idTH = @idTH -- Unir con TCA asegurando el idTH
        LEFT JOIN TCM TCM ON TF.CodigoTC = TCM.Codigo AND TCM.idTH = @idTH -- Unir con TCM asegurando el idTH
        WHERE 
            TCA.idTH = @idTH OR TCM.idTH = @idTH 
        ORDER BY 
            TF.FechaCreacion DESC;
        
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
/****** Object:  StoredProcedure [dbo].[ObtenerTodasLasTarjetas]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerTodasLasTarjetas]
    @inNombreUsuario VARCHAR(50),
    @OutResultCode INT OUTPUT  
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar si el usuario es administrador (cambiado para reflejar la nueva estructura de `UA` si aplica)
        IF EXISTS (
            SELECT 1
            FROM UA  -- Asegúrate de que `UA` existe y contiene los nombres de usuario
            WHERE Username = @inNombreUsuario
        )
        BEGIN
            -- Selección de tarjetas TCM y TCA unidas con TF y TH según la nueva estructura
            SELECT
                TF.Codigo AS NumeroTarjeta,
                CASE
                    WHEN TF.EsActiva = 1 THEN 'Activa'
                    ELSE 'Inactiva'
                END AS EstadoCuenta,
                CASE
                    WHEN TCA.id IS NOT NULL THEN 'TCA'
                    WHEN TCM.id IS NOT NULL THEN 'TCM'
                    ELSE NULL
                END AS TipoCuenta,
                TF.FechaVencimiento,
				TH.Nombre AS NombreTH
            FROM TF
            LEFT JOIN TCA ON TCA.Codigo = TF.CodigoTC
            LEFT JOIN TCM ON TCM.Codigo = TF.CodigoTC
			LEFT JOIN TH ON TCA.idTH = TH.id OR TCM.idTH = TH.id
			ORDER BY TF.FechaCreacion DESC;

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
        SET @OutResultCode = 50008;

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
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[verificarUsuario]    Script Date: 20/11/2024 01:23:28 ******/
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












--es este
ALTER PROCEDURE [dbo].[ObtenerEstadoCuenta]
    @IdTCM VARCHAR(64),
    @OutResultCode INT OUTPUT
AS
BEGIN
    BEGIN TRY

    SELECT
        EC.FechaCorte,
        EC.PagoMinimo,
        EC.PagoContratado,
        EC.InteresesCorrientes,
        EC.InteresesMoratorios,
        EC.CantidadOperacionesATM,
        EC.CantidadOperacionesVentanilla
    FROM EstadoCuenta EC
    WHERE EC.idTCM = @idTCM
    ORDER BY EC.FechaCorte DESC;

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
    END CATCH
END;
GO

/****** Object:  StoredProcedure [dbo].[ObtenerMovimientosPorTarjetaFisica]    Script Date: 20/11/2024 01:23:28 ******/
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO

-- CREATE PROCEDURE [dbo].[ObtenerMovimientosEstadoCuenta]
--     @OutResultCode INT OUTPUT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     -- Consulta para obtener los movimientos de la tarjeta física
--     SELECT 
--         M.FechaMovimiento AS [Fecha de Operación],
--         M.Nombre AS [Nombre de Tipo de Movimiento], -- Mantenemos el nombre directamente desde Movimiento
--         M.Descripcion AS [Descripción],
--         M.Referencia,
--         M.Monto,
--         -- Cálculo del nuevo saldo acumulado
--         SUM(M.Monto) OVER (PARTITION BY M.idTF ORDER BY M.FechaMovimiento ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Nuevo Saldo]
--     FROM Movimiento M
--     INNER JOIN TF ON M.idTF = TF.id
--     WHERE TF.CodigoTC = @inCodigoTarjetaFisica -- Filtro por el código de la tarjeta física
--     ORDER BY M.FechaMovimiento ASC; -- Orden por fecha
-- END;
-- GO

