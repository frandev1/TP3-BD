USE [sistemaTarjetaCredito]
GO

CREATE TRIGGER [dbo].[trInsertTCM]
	ON [dbo].[TCM]
	AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	--INSERTA UN ESTADO DE CUENTA POR CADA TARJETA NUEVA
	INSERT INTO sistemaTarjetaCredito.dbo.EstadoCuenta (
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
		I.id,
		DATEADD(MONTH, 1, I.FechaCreacion),
		0,
		0,
		0,
		DATEADD(DAY, 10, DATEADD(DAY, 10, I.FechaCreacion)),
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
	FROM inserted I;
END
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
		,DATEADD(MONTH, 1, T.FechaCreacion)
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
	FROM inserted I
	JOIN TCM T ON T.id = I.id;
END
GO

ALTER TRIGGER [dbo].[trUpdateTF]
ON dbo.TF
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Declaración de variables
    DECLARE @CodigoTC VARCHAR(64);
    DECLARE @NuevoVIN BIGINT; -- El nuevo VIN será un número generado aleatoriamente
    DECLARE @TipoTC VARCHAR(64);
	DECLARE @idTCM INT;			-- Se declara idTCM en caso de que la TF sea de una TCM
    DECLARE @CantidadAnos FLOAT;
    DECLARE @NuevaFechaVencimiento DATE;
    DECLARE @NuevoCCV VARCHAR(4);

    -- Obtener el código de tarjeta actualizado
    SELECT 
        @CodigoTC = U.CodigoTC
    FROM inserted U;

    -- Determinar el tipo de tarjeta
    SELECT
        @TipoTC =
            CASE
                WHEN TCA.id IS NOT NULL THEN 'TCA'
                WHEN TCM.id IS NOT NULL THEN 'TCM'
                ELSE NULL
            END
    FROM [sistemaTarjetaCredito].[dbo].[TF] TF
    LEFT JOIN TCA TCA ON TF.CodigoTC = TCA.Codigo
    LEFT JOIN TCM TCM ON TF.CodigoTC = TCM.Codigo
    WHERE TF.CodigoTC = @CodigoTC;

    -- Solo actuar si la tarjeta fue inactivada
    IF EXISTS (
        SELECT 1 
        FROM inserted U
        WHERE U.CodigoTC = @CodigoTC AND U.EsActiva = 0
    )
    BEGIN
		IF @TipoTC = 'TCM'
		BEGIN

			--Obtener el id del TCM
			SELECT
				@idTCM = TCM.id
			FROM [sistemaTarjetaCredito].[dbo].[TF] TF
			LEFT JOIN TCM TCM ON TF.CodigoTC = TCM.Codigo
			WHERE TF.CodigoTC = @CodigoTC;

			-- Obtener la cantidad de años para la nueva fecha de vencimiento
			SELECT @CantidadAnos = RN.Valor
			FROM RN RN
			WHERE RN.Nombre = 'Cantidad de Años para Vencimiento de TF'
			AND RN.idTTCM = (
				SELECT idTTCM
				FROM TCM
				WHERE id = @idTCM
			);

			-- Calcular la nueva fecha de vencimiento
			SET @NuevaFechaVencimiento = DATEADD(YEAR, @CantidadAnos, GETDATE());

			-- Generar un nuevo VIN como un número aleatorio único
			SET @NuevoVIN = ABS(CHECKSUM(NEWID()) % 10000000000000000);

			-- Validar que el nuevo VIN no exista ya en la tabla
			WHILE EXISTS (SELECT 1 FROM dbo.TF WHERE Codigo = @NuevoVIN)
			BEGIN
				SET @NuevoVIN = ABS(CHECKSUM(NEWID()) % 10000000000000000);
			END;

			-- Generar un nuevo CCV aleatorio (3 dígitos)
			SET @NuevoCCV = RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3);

			-- Insertar la nueva tarjeta física en la tabla TF
			INSERT INTO [dbo].[TF]
			([Codigo]
			,[CodigoTC]
			,[FechaVencimiento]
			,[CCV]
			,[EsActiva]
			,[FechaCreacion]
			,[idMotivoInvalidacion])
			VALUES
			(@NuevoVIN,             -- Nuevo VIN generado
				@CodigoTC,            -- Código de la tarjeta asociada
				@NuevaFechaVencimiento, -- Nueva fecha de vencimiento
				@NuevoCCV,            -- Nuevo CCV
				1,                    -- Activar la tarjeta
				GETDATE(),            -- Fecha de creación actual
				NULL);                -- Sin motivo de inactivación
		END
		ELSE
		BEGIN
			--Obtener el id del TCM
			SELECT
				@idTCM = TCA.idTCM
			FROM [sistemaTarjetaCredito].[dbo].[TF] TF
			LEFT JOIN TCA TCA ON TF.CodigoTC = TCA.Codigo
			WHERE TF.CodigoTC = @CodigoTC;

			-- Obtener la cantidad de años para la nueva fecha de vencimiento
			SELECT @CantidadAnos = RN.Valor
			FROM RN RN
			WHERE RN.Nombre = 'Cantidad de Años para Vencimiento de TF'
			AND RN.idTTCM = (
				SELECT idTTCM
				FROM TCM
				WHERE id = @idTCM
			)
			;

			-- Calcular la nueva fecha de vencimiento
			SET @NuevaFechaVencimiento = DATEADD(YEAR, @CantidadAnos, GETDATE());

			-- Generar un nuevo VIN como un número aleatorio único
			SET @NuevoVIN = ABS(CHECKSUM(NEWID()) % 10000000000000000);

			-- Validar que el nuevo VIN no exista ya en la tabla
			WHILE EXISTS (SELECT 1 FROM dbo.TF WHERE Codigo = @NuevoVIN)
			BEGIN
				SET @NuevoVIN = ABS(CHECKSUM(NEWID()) % 10000000000000000);
			END;

			-- Generar un nuevo CCV aleatorio (3 dígitos)
			SET @NuevoCCV = RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3);

			-- Insertar la nueva tarjeta física en la tabla TF
			INSERT INTO [dbo].[TF]
			([Codigo]
			,[CodigoTC]
			,[FechaVencimiento]
			,[CCV]
			,[EsActiva]
			,[FechaCreacion]
			,[idMotivoInvalidacion])
			VALUES
			(@NuevoVIN,             -- Nuevo VIN generado
			@CodigoTC,            -- Código de la tarjeta asociada
			@NuevaFechaVencimiento, -- Nueva fecha de vencimiento
			@NuevoCCV,            -- Nuevo CCV
			1,                    -- Activar la tarjeta
			GETDATE(),            -- Fecha de creación actual
			NULL);                -- Sin motivo de inactivación
		END
    END
END;
GO



