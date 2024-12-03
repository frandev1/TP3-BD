/****** Object:  StoredProcedure [dbo].[ObtenerEstadoCuenta]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerEstadoCuenta]
    @InCodigoTF VARCHAR(64),
    @InTipoTF VARCHAR(4),
    @OutResultCode INT OUTPUT
AS
BEGIN
    BEGIN TRY

    SET @OutResultCode = 0;

	DECLARE @idTC INT;

    IF (@InTipoTF = 'TCM')
    BEGIN 
        SELECT
            EC.FechaCorte,
            EC.PagoMinimo,
            EC.PagoContado,
            EC.InteresesCorrientes,
            EC.InteresesMoratorios,
            EC.CantidadOperacionesATM,
            EC.CantidadOperacionesVentanilla
        FROM EstadoCuenta EC
        INNER JOIN TF ON TF.Codigo = @InCodigoTF
        WHERE EC.idTCM = TF.idTCM
        ORDER BY EC.FechaCorte DESC;
    END
    
    IF (@InTipoTF = 'TCA')
    BEGIN

        SELECT
            @idTC = TCA.id
        FROM TCA
        INNER JOIN TF ON TF.Codigo = @InCodigoTF
        WHERE TCA.Codigo = TF.idTCA;
        
        SELECT
            SEC.FechaCorte,
            SEC.CantidadOperacionesATM,
            SEC.CantidadOperacionesVentanilla,
            SEC.CantidadCompras,
            SEC.SumaCompras,
            SEC.CantidadRetiros,
            SEC.SumaRetiros
        FROM SubEstadoCuenta SEC
        INNER JOIN TF ON TF.Codigo = @InCodigoTF
        WHERE SEC.idTCA = TF.idTCA
        ORDER BY SEC.FechaCorte DESC;
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
        
        SET @OutResultCode = 0;

        DECLARE @idTH INT;

        -- Obtener el id del tarjetahabiente (TH) basado en el nombre de usuario
        SELECT @idTH = TH.id
        FROM [dbo].[TH] TH
        INNER JOIN [dbo].[Usuario] U ON TH.idUsuario = U.id
        WHERE U.Username = @inUsuarioTH;

        -- Verificar si el tarjetahabiente existe
        IF @idTH IS NULL
        BEGIN
            SET @OutResultCode = 50002;  
            RAISERROR('Usuario no encontrado.', 16, 1);
            RETURN;
        END;

        
        SELECT DISTINCT
            TF.Codigo AS NumeroTarjeta,        
            CASE
                WHEN TF.EsActiva = 1 THEN 'Activa'
                ELSE 'Inactiva'
            END AS EstadoCuenta,               
            TF.FechaVencimiento,               
            CASE
                WHEN TF.idTCA IS NOT NULL THEN 'TCA'
                WHEN TF.idTCM IS NOT NULL THEN 'TCM'
                ELSE NULL
            END AS TipoCuenta,                 
            TF.FechaCreacion                   
        FROM [dbo].[TF] TF
        LEFT JOIN [dbo].[TCA] TCA ON TF.idTCA = TCA.id AND TCA.idTH = @idTH
        LEFT JOIN [dbo].[TCM] TCM ON TF.idTCM = TCM.id AND TCM.idTH = @idTH
        WHERE TCA.idTH = @idTH OR TCM.idTH = @idTH
        ORDER BY TF.FechaCreacion DESC;

    END TRY
    BEGIN CATCH
        
        SET @OutResultCode = 50008;

        
        INSERT INTO [dbo].[DBError]
        (
            ErrorUserName,
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
        -- Verificar si el usuario es administrador
        IF EXISTS (
            SELECT 1
            FROM Usuario
            WHERE Username = @inNombreUsuario AND TipoUsuario = 1
        )
        BEGIN
            -- Seleccionar información de las tarjetas
            SELECT
                TF.Codigo AS NumeroTarjeta,
                CASE
                    WHEN TF.EsActiva = 1 THEN 'Activa'
                    ELSE 'Inactiva'
                END AS EstadoCuenta,
                CASE
                    WHEN TF.idTCA IS NOT NULL THEN 'TCA'
                    WHEN TF.idTCM IS NOT NULL THEN 'TCM'
                    ELSE NULL
                END AS TipoCuenta,
                TF.FechaVencimiento,
                TH.Nombre AS NombreTH
            FROM TF
            LEFT JOIN TCA ON TF.idTCA = TCA.id
            LEFT JOIN TCM ON TF.idTCM = TCM.id
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

        IF EXISTS (
            SELECT 1
            FROM [sistemaTarjetaCredito].[dbo].[Usuario] U
            WHERE U.Username = @inNombre
            AND U.Password = @inPassword
        )
        BEGIN
            SELECT
                @OutTipoUsuario = 
                    CASE
                        WHEN U.TipoUsuario = 0 THEN 1
                        WHEN U.TipoUsuario = 1 THEN 0
                    END,
                @OutNombre = TH.Nombre
            FROM [sistemaTarjetaCredito].[dbo].[Usuario] U
            LEFT JOIN TH ON TH.idUsuario = U.id
            WHERE U.Username = @inNombre
            AND U.Password = @inPassword 
        END
        ELSE
        BEGIN
            SET @OutResultCode = 50002
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
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[ObtenerMovimientos]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerMovimientos] (
    @inCodigoTC VARCHAR(50),
    @inTipoTC VARCHAR(50),
    @inFechaCorte DATE,
    @OutResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @OutResultCode = 0;

        DECLARE @idTC INT;

        -- Buscar el ID de la tarjeta
        SELECT @idTC = TF.id
        FROM TF
        WHERE TF.Codigo = @inCodigoTC;

        -- Movimientos para tarjetas adicionales (TCA)
        IF (@inTipoTC = 'TCA')
        BEGIN
            SELECT
                M.FechaMovimiento,
                TM.Nombre,
                M.Descripcion,
                M.Referencia,
                M.Monto,
                M.NuevoSaldo
            FROM Movimiento M
            INNER JOIN TM ON M.idTM = TM.id
            WHERE M.idTF = @idTC AND 
			M.FechaMovimiento BETWEEN DATEADD(MONTH, -1, @inFechaCorte) AND @inFechaCorte;
        END

		-- Movimientos para tarjetas maestras (TCM)
        IF (@inTipoTC = 'TCM')
        BEGIN
            SELECT
                M.FechaMovimiento,
                TM.Nombre,
                M.Descripcion,
                M.Referencia,
                M.Monto,
                M.NuevoSaldo
            FROM Movimiento M
            INNER JOIN TM ON M.idTM = TM.id
            INNER JOIN EstadoCuenta EC ON M.idEC = EC.id
            WHERE EC.FechaCorte = @inFechaCorte
                AND EC.idTCM = @idTC; -- Relaciona con el idTC de TCM
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @OutResultCode = 50008; -- Código genérico para error

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