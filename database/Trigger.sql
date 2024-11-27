USE [sistemaTarjetaCredito]
GO

CREATE TRIGGER [dbo].[trInsertTCM]
ON [dbo].[TCM]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Insertar en EstadoCuenta solo si no existen registros para el mismo idTCM
    INSERT INTO sistemaTarjetaCredito.dbo.EstadoCuenta
    (
        idTCM,
        FechaCorte,
        SaldoActual,
        PagoContratado,
        PagoMinimo,
        FechaPago,
        InteresesCorrientes,
        InteresesMoratorios,
        CantidadOperacionesATM,
        CantidadOperacionesVentanilla,
        SumaPagosAntesFecha,
        SumaPagosMes,
        CantidadPagosMes,
        CantidadCompras,
        CantidadRetiros,
        SumaCompras,
        SumaRetiros,
        CantidadCreditos,
        SumaCreditos,
        CantidadDebitos,
        SumaDebitos
    )
    SELECT
        i.id,
        DATEADD(MONTH, 1, i.FechaCreacion),
        0,
        0,
        0,
        DATEADD(DAY, RN.Valor, DATEADD(MONTH, 1, i.FechaCreacion)),
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
    FROM inserted i
	INNER JOIN dbo.TH TH ON i.idTH = TH.id
	INNER JOIN dbo.TTCM TTCM ON i.idTTCM = TTCM.id
	INNER JOIN dbo.TRN TRN ON TRN.Nombre = 'Cantidad de dias'
	INNER JOIN dbo.RN RN ON RN.idTRN = TRN.id 
							AND RN.idTTCM = i.idTTCM 
							AND RN.Nombre = 'Cantidad de dias para pago saldo de contado'
END;
GO



CREATE TRIGGER [dbo].[trInsertTCA]
	ON [dbo].[TCA]
	AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    --INSERTA UN ESTADO DE CUENTA POR CADA TARJETA NUEVA
    INSERT INTO  [dbo].[SubEstadoCuenta]
        ([idTCA]
        ,[FechaCorte]
        ,[CantidadOperaciones]
        ,[CantidadOperacionesATM]
        ,[SumaCompras]
        ,[SumaRetiros]
        ,[CantidadRetiros]
        ,[SumaCreditos]
        ,[SumaDebitos])
    SELECT
        I.id
		, DATEADD(MONTH, 1, T.FechaCreacion)
        , 0
        , 0
        , 0
        , 0
        , 0
        , 0
        , 0
    FROM inserted I
        JOIN TCM T ON T.id = I.id;
END
GO

CREATE TRIGGER [dbo].[trUpdateTF]
ON dbo.TF
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Declaración de variables
    DECLARE @CodigoTC VARCHAR(64);
    DECLARE @NuevoVIN VARCHAR(16);
    -- El nuevo VIN será un número generado aleatoriamente
    DECLARE @TipoTC VARCHAR(64);
    DECLARE @idTCM INT;
    -- ID del TCM si aplica
    DECLARE @CantidadAnos FLOAT;
    DECLARE @NuevaFechaVencimiento DATE;
    DECLARE @NuevoCCV VARCHAR(4);
    DECLARE @Largo INT;
    DECLARE @Contador INT;

    -- Crear una tabla temporal para las tarjetas inactivadas
    DECLARE @TarjetasInactivadas TABLE (
        id INT IDENTITY(1,1),
        CodigoTC VARCHAR(64),
        TipoTC VARCHAR(64)
    );

    -- Poblar la tabla temporal con las tarjetas afectadas
    INSERT INTO @TarjetasInactivadas
        (CodigoTC, TipoTC)
    SELECT
        I.CodigoTC,
        CASE
            WHEN TCA.id IS NOT NULL THEN 'TCA'
            WHEN TCM.id IS NOT NULL THEN 'TCM'
            ELSE NULL
        END AS TipoTC
    FROM inserted I
        LEFT JOIN TCA ON I.CodigoTC = TCA.Codigo
        LEFT JOIN TCM ON I.CodigoTC = TCM.Codigo
    WHERE I.EsActiva = 0;
    -- Solo procesar tarjetas que fueron inactivadas

    -- Obtener el número de filas en la tabla temporal
    SELECT @Largo = COUNT(*)
    FROM @TarjetasInactivadas;

    -- Inicializar el contador
    SET @Contador = 1;

    -- Procesar cada tarjeta inactivada
    WHILE @Contador <= @Largo
    BEGIN
        -- Obtener los datos de la tarjeta actual
        SELECT
            @CodigoTC = CodigoTC,
            @TipoTC = TipoTC
        FROM @TarjetasInactivadas
        WHERE id = @Contador;

        -- Validar si es TCM o TCA
        IF @TipoTC = 'TCM'
        BEGIN
            -- Obtener el idTCM
            SELECT @idTCM = TCM.id
            FROM TCM
            WHERE TCM.Codigo = @CodigoTC;

            -- Obtener la cantidad de años para el vencimiento
            SELECT @CantidadAnos = RN.Valor
            FROM RN
            WHERE RN.Nombre = 'Cantidad de Años para Vencimiento de TF'
                AND RN.idTTCM = (
                  SELECT idTTCM
                FROM TCM
                WHERE id = @idTCM
              );

            -- Calcular la nueva fecha de vencimiento
            SET @NuevaFechaVencimiento = DATEADD(YEAR, @CantidadAnos, GETDATE());

            SET @NuevoVIN = CAST(ABS(CHECKSUM(NEWID())) AS BIGINT);

            WHILE LEN(@NuevoVIN) < 16
            BEGIN 
                SET @NuevoVIN = @NuevoVIN + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR);
            END

            SET @NuevoVIN = LEFT(@NuevoVIN, 16);

            WHILE EXISTS (SELECT 1 FROM TF WHERE Codigo = @NuevoVIN) --Verificar si solo hay ese o como es la vara
            BEGIN

                --Hacer la vara de nuevo en caso de que haya uno ahí medio parecido en la trama
                SET @NuevoVIN = CAST(ABS(CHECKSUM(NEWID())) AS BIGINT);

                WHILE LEN(@NuevoVIN) < 16
                BEGIN
                    SET @NuevoVIN = @NuevoVIN + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR);
                END

                SET @NuevoVIN = LEFT(@NuevoVIN, 16);
            END

            -- Generar un nuevo CCV aleatorio (4 dígitos)
            SET @NuevoCCV = RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID())) % 10000) AS VARCHAR), 4);

            -- Insertar la nueva tarjeta física
            INSERT INTO TF
                (Codigo, CodigoTC, FechaVencimiento, CCV, EsActiva, FechaCreacion, idMotivoInvalidacion)
            VALUES
                (@NuevoVIN, @CodigoTC, @NuevaFechaVencimiento, @NuevoCCV, 1, GETDATE(), NULL);
        END
        ELSE IF @TipoTC = 'TCA'
        BEGIN
            -- Obtener el idTCM asociado a la TCA
            SELECT @idTCM = TCA.idTCM
            FROM TCA
            WHERE TCA.Codigo = @CodigoTC;

            -- Obtener la cantidad de años para el vencimiento
            SELECT @CantidadAnos = RN.Valor
            FROM RN
            WHERE RN.Nombre = 'Cantidad de Años para Vencimiento de TF'
                AND RN.idTTCM = (
                  SELECT idTTCM
                FROM TCM
                WHERE id = @idTCM
              );

            -- Calcular la nueva fecha de vencimiento
            SET @NuevaFechaVencimiento = DATEADD(YEAR, @CantidadAnos, GETDATE());

            SET @NuevoVIN = CAST(ABS(CHECKSUM(NEWID())) AS BIGINT);

            WHILE LEN(@NuevoVIN) < 16
            BEGIN 
                SET @NuevoVIN = @NuevoVIN + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR);
            END

            SET @NuevoVIN = LEFT(@NuevoVIN, 16);

            WHILE EXISTS (SELECT 1 FROM TF WHERE Codigo = @NuevoVIN) --Verificar si solo hay ese o como es la vara
            BEGIN

                --Hacer la vara de nuevo en caso de que haya uno ahí medio parecido en la trama
                SET @NuevoVIN = CAST(ABS(CHECKSUM(NEWID())) AS BIGINT);

                WHILE LEN(@NuevoVIN) < 16
                BEGIN
                    SET @NuevoVIN = @NuevoVIN + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR);
                END

                SET @NuevoVIN = LEFT(@NuevoVIN, 16);
            END

            -- Generar un nuevo CCV aleatorio (3 dígitos)
            SET @NuevoCCV = RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 4);

            -- Insertar la nueva tarjeta física
            INSERT INTO TF
                (Codigo, CodigoTC, FechaVencimiento, CCV, EsActiva, FechaCreacion, idMotivoInvalidacion)
            VALUES
                (@NuevoVIN, @CodigoTC, @NuevaFechaVencimiento, @NuevoCCV, 1, GETDATE(), NULL);
        END

        -- Incrementar el contador
        SET @Contador = @Contador + 1;
    END
END;
GO

CREATE TRIGGER [dbo].[trUpdateEstadoCuentaOnMovimiento]
ON [dbo].[Movimiento]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualización de EstadoCuenta para tarjetas maestras (TCM)
    UPDATE EC
    SET 
        EC.SaldoActual = EC.SaldoActual + 
            CASE 
                WHEN I.Nombre IN ('Compra', 'Retiro', 'Debito') THEN -I.Monto
                WHEN I.Nombre = 'Credito' THEN I.Monto
                ELSE 0 
            END,
        EC.CantidadCompras = EC.CantidadCompras + 
            CASE WHEN I.Nombre = 'Compra' THEN 1 ELSE 0 END,
        EC.SumaCompras = EC.SumaCompras + 
            CASE WHEN I.Nombre = 'Compra' THEN I.Monto ELSE 0 END,
        EC.CantidadRetiros = EC.CantidadRetiros + 
            CASE WHEN I.Nombre = 'Retiro' THEN 1 ELSE 0 END,
        EC.SumaRetiros = EC.SumaRetiros + 
            CASE WHEN I.Nombre = 'Retiro' THEN I.Monto ELSE 0 END,
        EC.CantidadCreditos = EC.CantidadCreditos + 
            CASE WHEN I.Nombre = 'Credito' THEN 1 ELSE 0 END,
        EC.SumaCreditos = EC.SumaCreditos + 
            CASE WHEN I.Nombre = 'Credito' THEN I.Monto ELSE 0 END,
        EC.CantidadDebitos = EC.CantidadDebitos + 
            CASE WHEN I.Nombre = 'Debito' THEN 1 ELSE 0 END,
        EC.SumaDebitos = EC.SumaDebitos + 
            CASE WHEN I.Nombre = 'Debito' THEN I.Monto ELSE 0 END
    FROM EstadoCuenta EC
        INNER JOIN TCM ON EC.idTCM = TCM.id
        INNER JOIN TF ON TCM.Codigo = TF.CodigoTC
        INNER JOIN inserted I ON I.idTF = TF.id
    WHERE EC.FechaCorte >= I.FechaMovimiento;

    -- Actualización de SubEstadoCuenta para tarjetas adicionales (TCA)
    UPDATE SEC
    SET 
        SEC.SumaCompras = SEC.SumaCompras + 
            CASE WHEN I.Nombre = 'Compra' THEN I.Monto ELSE 0 END,
        SEC.SumaRetiros = SEC.SumaRetiros + 
            CASE WHEN I.Nombre = 'Retiro' THEN I.Monto ELSE 0 END,
        SEC.CantidadRetiros = SEC.CantidadRetiros + 
            CASE WHEN I.Nombre = 'Retiro' THEN 1 ELSE 0 END,
        SEC.SumaCreditos = SEC.SumaCreditos + 
            CASE WHEN I.Nombre = 'Credito' THEN I.Monto ELSE 0 END,
        SEC.SumaDebitos = SEC.SumaDebitos + 
            CASE WHEN I.Nombre = 'Debito' THEN I.Monto ELSE 0 END
    FROM SubEstadoCuenta SEC
        INNER JOIN TCA ON SEC.idTCA = TCA.id
        INNER JOIN TF ON TCA.Codigo = TF.CodigoTC
        INNER JOIN inserted I ON I.idTF = TF.id
    WHERE SEC.FechaCorte >= I.FechaMovimiento;

END;
GO


