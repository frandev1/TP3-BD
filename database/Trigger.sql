USE [sistemaTarjetaCredito]
GO

CREATE TRIGGER [dbo].[trInsertTCM]
ON [dbo].[TCM]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT OFF;
	BEGIN TRY
		BEGIN TRANSACTION
		-- Insertar en EstadoCuenta solo si no existen registros para el mismo idTCM
		INSERT INTO sistemaTarjetaCredito.dbo.EstadoCuenta
			(
			idTCM,
			FechaCorte,
			SaldoActual,
			PagoContado,
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
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		-- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

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



CREATE TRIGGER [dbo].[trInsertTCA]
	ON [dbo].[TCA]
	AFTER INSERT
AS
BEGIN
    SET NOCOUNT OFF;
	BEGIN TRY
		BEGIN TRANSACTION
		--INSERTA UN ESTADO DE CUENTA POR CADA TARJETA NUEVA
		INSERT INTO  [dbo].[SubEstadoCuenta]
			([idTCA]
			,[FechaCorte]
			,[CantidadOperacionesATM]
			,[CantidadOperacionesVentanilla]
			,[SumaCompras]
			,[CantidadCompras]
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
			, 0
		FROM inserted I
			JOIN TCM T ON T.id = I.id;
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		-- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION;
        END;
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

CREATE TRIGGER [dbo].[trUpdateTF]
ON dbo.TF
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		-- Declaración de variables
		DECLARE @idTC INT;
		DECLARE @idTCM INT;
		DECLARE @NuevoVIN VARCHAR(16);
		-- El nuevo VIN será un número generado aleatoriamente
		DECLARE @TipoTC VARCHAR(64);
		DECLARE @CantidadAnos FLOAT;
		DECLARE @NuevaFechaVencimiento DATE;
		DECLARE @FechaInvalidacion DATE;
		DECLARE @NuevoCCV VARCHAR(4);
		DECLARE @Largo INT;
		DECLARE @Contador INT;
		DECLARE @idMotivoInvalidacion INT;
		DECLARE @Referencia VARCHAR(64);

		-- Crear una tabla temporal para las tarjetas inactivadas
		DECLARE @TarjetasInactivadas TABLE (
			id INT IDENTITY(1,1),
			idTC VARCHAR(64),
			TipoTC VARCHAR(64),
			FechaInvalidacion DATE,
			idMotivoInvalidacion INT
		);

		-- Poblar la tabla temporal con las tarjetas afectadas
		INSERT INTO @TarjetasInactivadas
			(idTC, TipoTC, FechaInvalidacion, idMotivoInvalidacion)
		SELECT
			CASE
				WHEN I.idTCA IS NOT NULL THEN I.idTCA
				WHEN I.idTCM IS NOT NULL THEN I.idTCM
			END,
			CASE
				WHEN I.idTCA IS NOT NULL THEN 'TCA'
				WHEN I.idTCM IS NOT NULL THEN 'TCM'
				ELSE NULL
			END AS TipoTC,
			I.FechaInvalidacion,
			I.idMotivoInvalidacion
		FROM inserted I
			LEFT JOIN TCA ON I.idTCA = TCA.id
			LEFT JOIN TCM ON I.idTCM = TCM.Codigo
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
				@idTC = idTC,
				@TipoTC = TipoTC,
				@FechaInvalidacion = FechaInvalidacion,
				@idMotivoInvalidacion = idMotivoInvalidacion
			FROM @TarjetasInactivadas
			WHERE id = @Contador;

			-- Validar si es TCM o TCA
			IF @TipoTC = 'TCM'
			BEGIN

				-- Obtener la cantidad de años para el vencimiento
				SELECT @CantidadAnos = RN.Valor
				FROM RN
				WHERE RN.Nombre = 'Cantidad de Años para Vencimiento de TF'
					AND RN.idTTCM = (
					  SELECT idTTCM
					FROM TCM
					WHERE id = @idTC
				  );

				-- Calcular la nueva fecha de vencimiento
				SELECT
					@NuevaFechaVencimiento = DATEADD(YEAR, @CantidadAnos, @FechaInvalidacion)
				From @TarjetasInactivadas
				WHERE id = @Contador

				SET @NuevoVIN = CAST(ABS(CHECKSUM(NEWID())) AS BIGINT);

				WHILE LEN(@NuevoVIN) < 16
				BEGIN
					SET @NuevoVIN = @NuevoVIN + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR);
				END

				SET @NuevoVIN = LEFT(@NuevoVIN, 16);

				WHILE EXISTS (SELECT 1
				FROM TF
				WHERE Codigo = @NuevoVIN) --Verificar si solo hay ese o como es la vara
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
				INSERT INTO TF (
					Codigo, 
					idTCM, 
					FechaVencimiento, 
					CCV, 
					EsActiva, 
					FechaCreacion
					)
				VALUES
					(@NuevoVIN, 
					@idTC, 
					@NuevaFechaVencimiento, 
					@NuevoCCV, 
					1, 
					@FechaInvalidacion
					);

				SET @Referencia = LEFT(NEWID(), 5);
				WHILE EXISTS (SELECT 1 FROM Movimiento WHERE Referencia = @Referencia)
				BEGIN
					SET @Referencia = LEFT(NEWID(), 5);
				END
            
				INSERT INTO Movimiento (
					idTM,
					idEC,
					idTF,
					FechaMovimiento,
					Monto,
					Descripcion,
					Referencia
				)
				SELECT
					9,
					EC.id,
					TF.id,
					@FechaInvalidacion,
					RN.Valor,
					CASE
						WHEN @idMotivoInvalidacion = 1 THEN 'Renovacion por Robo'
						WHEN @idMotivoInvalidacion = 2 THEN 'Renovacion por Perdida'
						ELSE 'Renovacion por Vencimiento'
					END,
					@Referencia
				FROM TF
				INNER JOIN RN ON RN.Nombre = 'Cargo renovacion de TF de TCM'
					AND RN.idTTCM = (
						SELECT idTTCM
							FROM TCM
						WHERE id = @idTC
						)
				INNER JOIN EstadoCuenta EC ON EC.idTCM = @idTC 
					AND DATEDIFF(MONTH, @FechaInvalidacion, EC.FechaCorte) BETWEEN 0 AND 1
				WHERE TF.Codigo = @NuevoVIN

			END
			ELSE IF @TipoTC = 'TCA'
			BEGIN
				-- Obtener el idTCM asociado a la TCA
				SELECT @idTCM = TCA.idTCM
				FROM TCA
				WHERE TCA.id = @idTC;

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
				-- Calcular la nueva fecha de vencimiento
				SELECT
					@NuevaFechaVencimiento = DATEADD(YEAR, @CantidadAnos, @FechaInvalidacion)
				From @TarjetasInactivadas
				WHERE id = @Contador

				SET @NuevoVIN = CAST(ABS(CHECKSUM(NEWID())) AS BIGINT);

				WHILE LEN(@NuevoVIN) < 16
				BEGIN
					SET @NuevoVIN = @NuevoVIN + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR);
				END

				SET @NuevoVIN = LEFT(@NuevoVIN, 16);

				WHILE EXISTS (SELECT 1
				FROM TF
				WHERE Codigo = @NuevoVIN) --Verificar si solo hay ese o como es la vara
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
				INSERT INTO TF (
					Codigo, 
					idTCA, 
					FechaVencimiento, 
					CCV, 
					EsActiva, 
					FechaCreacion
					)
				VALUES (
					@NuevoVIN, 
					@idTC, 
					@NuevaFechaVencimiento, 
					@NuevoCCV, 
					1, 
					@FechaInvalidacion
					);
			
				SET @Referencia = LEFT(NEWID(), 5);
				WHILE EXISTS (SELECT 1 FROM Movimiento WHERE Referencia = @Referencia)
				BEGIN
					SET @Referencia = LEFT(NEWID(), 5);
				END
            
            
				INSERT INTO Movimiento (
					idTM,
					idEC,
					idTF,
					FechaMovimiento,
					Monto,
					Descripcion,
					Referencia
				)
				SELECT
					9,
					EC.id,
					TF.id,
					@FechaInvalidacion,
					RN.Valor,
					CASE
						WHEN @idMotivoInvalidacion = 1 THEN 'Renovacion por Robo'
						WHEN @idMotivoInvalidacion = 2 THEN 'Renovacion por Perdida'
						ELSE 'Renovacion por Vencimiento'
					END,
					@Referencia
				FROM TF
				INNER JOIN RN ON RN.Nombre = 'Cargo renovacion de TF de TCA'
					AND RN.idTTCM = (
						SELECT idTTCM
							FROM TCM
						WHERE id = @idTCM
						)
				INNER JOIN EstadoCuenta EC ON EC.idTCM = @idTCM 
					AND DATEDIFF(MONTH, @FechaInvalidacion, EC.FechaCorte) BETWEEN 0 AND 1
				WHERE TF.Codigo = @NuevoVIN
			END

			-- Incrementar el contador
			SET @Contador = @Contador + 1;
		END
	END TRY
	BEGIN CATCH
		-- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

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

CREATE TRIGGER [dbo].[trUpdateEstadoCuentaOnMovimiento]
ON [dbo].[Movimiento]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para manejar cada fila del movimiento insertado
    DECLARE @idTF INT;
    DECLARE @idTC VARCHAR(64);
    DECLARE @TipoTC VARCHAR(4);
    DECLARE @NombreMovimiento VARCHAR(64);
    DECLARE @Monto MONEY;
	DECLARE @FechaMovimiento DATE;
	DECLARE @Largo INT;
	DECLARE @Contador INT;

	INSERT INTO MovimientoSospechoso(
		idMovimiento
	)
	SELECT I.id
	FROM inserted I
	INNER JOIN TF ON TF.id = I.idTF
	WHERE TF.EsActiva = 0;

	DECLARE @MovimientoNoSospechoso TABLE (
		id INT IDENTITY(1,1),
		idTF INT,
		Nombre VARCHAR(64),
		Monto MONEY,
		idTC VARCHAR(64),
		TipoTC VARCHAR(8),
		FechaMovimiento DATE
	)

	INSERT INTO @MovimientoNoSospechoso (
		idTF,
		Nombre,
		Monto,
		idTC,
		TipoTC,
		FechaMovimiento
	)
    -- Procesar cada fila del conjunto insertado
    SELECT
        I.idTF,
        TM.Nombre,
        I.Monto,
		CASE
			WHEN TF.idTCA IS NOT NULL THEN TF.idTCA
			WHEN TF.idTCM IS NOT NULL THEN TF.idTCM
            ELSE NULL
        END,
        CASE
			WHEN TF.idTCA IS NOT NULL THEN 'TCA'
			WHEN TF.idTCM IS NOT NULL THEN 'TCM'
            ELSE NULL
        END,
		I.FechaMovimiento
    FROM inserted I
        LEFT JOIN TF ON I.idTF = TF.id
		INNER JOIN TM ON TM.id = I.idTM
	WHERE I.id NOT IN (SELECT idMovimiento FROM MovimientoSospechoso)

	SET @Contador = 1;

	SELECT @Largo = COUNT(*)
    FROM @MovimientoNoSospechoso;

	WHILE @Contador <= @Largo
	BEGIN
		SELECT
			@idTF = MNS.idTF,
			@NombreMovimiento = MNS.Nombre,
			@Monto = MNS.Monto,
			@idTC = MNS.idTC,
			@TipoTC = MNS.TipoTC,
			@FechaMovimiento = MNS.FechaMovimiento
		FROM @MovimientoNoSospechoso MNS
		WHERE MNS.id = @Contador;

		-- Actualización en EstadoCuenta (para tarjetas maestras - TCM)
		IF @TipoTC = 'TCM'
		BEGIN
			UPDATE EC
			SET 
				EC.SaldoActual = EC.SaldoActual + 
					CASE 
						WHEN TM.Accion = 'Debito' THEN -@Monto
						WHEN TM.Accion = 'Credito' THEN @Monto
						ELSE 0
					END,
				EC.CantidadOperacionesATM = EC.CantidadOperacionesATM + 
					CASE 
						WHEN TM.AcumulaOperacionesATM = 1 THEN 1 
						ELSE 0 
					END,
				EC.CantidadOperacionesVentanilla = EC.CantidadOperacionesVentanilla + 
					CASE 
						WHEN TM.AcumulaOperacionesVentana = 1 THEN 1 
						ELSE 0 
					END,
				EC.SumaPagosAntesFecha = EC.SumaPagosAntesFecha +
					CASE
						WHEN @NombreMovimiento IN ('Pago en ATM',
						'Pago en Linea') THEN @Monto ELSE 0 
					END,
				EC.SumaPagosMes = EC.SumaPagosMes +
					CASE
						WHEN @NombreMovimiento IN ('Pago en ATM',
						'Pago en Linea') THEN @Monto ELSE 0 
					END,
				EC.CantidadPagosMes = EC.CantidadPagosMes +
					CASE
						WHEN @NombreMovimiento IN ('Pago en ATM',
						'Pago en Linea') THEN 1 ELSE 0
					END, 
				EC.CantidadCompras = EC.CantidadCompras + 
					CASE WHEN @NombreMovimiento = 'Compra' THEN 1 ELSE 0 END,
				EC.CantidadRetiros = EC.CantidadRetiros + 
					CASE WHEN @NombreMovimiento IN ('Retiro en Ventana', 
					'Retiro en ATM') THEN 1 ELSE 0 END,
				EC.SumaCompras = EC.SumaCompras + 
					CASE WHEN @NombreMovimiento = 'Compra' THEN @Monto ELSE 0 END,
				EC.SumaRetiros = EC.SumaRetiros + 
					CASE WHEN @NombreMovimiento IN ('Retiro en Ventana', 
					'Retiro en ATM') THEN @Monto ELSE 0 END,
				EC.CantidadCreditos = EC.CantidadCreditos +
					CASE WHEN TM.Accion = 'Credito' THEN 1 ELSE 0 END,
				EC.SumaCreditos = EC.SumaCreditos +
					CASE WHEN TM.Accion = 'Credito' THEN @Monto ELSE 0 END,
				EC.CantidadDebitos = EC.CantidadDebitos +
					CASE WHEN TM.Accion = 'Debito' THEN 1 ELSE 0 END,
				EC.SumaDebitos = EC.SumaDebitos +
					CASE WHEN TM.Accion = 'Debito' THEN @Monto ELSE 0 END
			FROM EstadoCuenta EC
				INNER JOIN TCM ON EC.idTCM = TCM.id AND TCM.id = @idTC
				INNER JOIN TM ON TM.Nombre = @NombreMovimiento
			WHERE DATEDIFF(MONTH, @FechaMovimiento, EC.FechaCorte) BETWEEN 0 AND 1;
		END

		-- Actualización en SubEstadoCuenta (para tarjetas adicionales - TCA)
		IF @TipoTC = 'TCA'
		BEGIN
			UPDATE EC
			SET 
				EC.SaldoActual = EC.SaldoActual + 
					CASE 
						WHEN TM.Accion = 'Debito' THEN -@Monto
						WHEN TM.Accion = 'Credito' THEN @Monto
						ELSE 0
					END,
				EC.CantidadOperacionesATM = EC.CantidadOperacionesATM + 
					CASE 
						WHEN TM.AcumulaOperacionesATM = 1 THEN 1 
						ELSE 0 
					END,
				EC.CantidadOperacionesVentanilla = EC.CantidadOperacionesVentanilla + 
					CASE 
						WHEN TM.AcumulaOperacionesVentana = 1 THEN 1 
						ELSE 0 
					END,
				EC.SumaPagosAntesFecha = EC.SumaPagosAntesFecha +
					CASE
						WHEN @NombreMovimiento IN ('Pago en ATM',
						'Pago en Linea') THEN @Monto ELSE 0 
					END,
				EC.SumaPagosMes = EC.SumaPagosMes +
					CASE
						WHEN @NombreMovimiento IN ('Pago en ATM',
						'Pago en Linea') THEN @Monto ELSE 0 
					END,
				EC.CantidadPagosMes = EC.CantidadPagosMes +
					CASE
						WHEN @NombreMovimiento IN ('Pago en ATM',
						'Pago en Linea') THEN 1 ELSE 0
					END, 
				EC.CantidadCompras = EC.CantidadCompras + 
					CASE WHEN @NombreMovimiento = 'Compra' THEN 1 ELSE 0 END,
				EC.CantidadRetiros = EC.CantidadRetiros + 
					CASE WHEN @NombreMovimiento IN ('Retiro en Ventana', 
					'Retiro en ATM') THEN 1 ELSE 0 END,
				EC.SumaCompras = EC.SumaCompras + 
					CASE WHEN @NombreMovimiento = 'Compra' THEN @Monto ELSE 0 END,
				EC.SumaRetiros = EC.SumaRetiros + 
					CASE WHEN @NombreMovimiento IN ('Retiro en Ventana', 
					'Retiro en ATM') THEN @Monto ELSE 0 END,
				EC.CantidadCreditos = EC.CantidadCreditos +
					CASE WHEN TM.Accion = 'Credito' THEN 1 ELSE 0 END,
				EC.SumaCreditos = EC.SumaCreditos +
					CASE WHEN TM.Accion = 'Credito' THEN @Monto ELSE 0 END,
				EC.CantidadDebitos = EC.CantidadDebitos +
					CASE WHEN TM.Accion = 'Debito' THEN 1 ELSE 0 END,
				EC.SumaDebitos = EC.SumaDebitos +
					CASE WHEN TM.Accion = 'Debito' THEN @Monto ELSE 0 END
			FROM EstadoCuenta EC
				INNER JOIN TCA ON EC.idTCM = TCA.idTCM AND TCA.id = @idTC
				INNER JOIN TM ON TM.Nombre = @NombreMovimiento
			WHERE DATEDIFF(MONTH, @FechaMovimiento, EC.FechaCorte) BETWEEN 0 AND 1;

			UPDATE SEC
			SET 
				SEC.CantidadOperacionesATM = SEC.CantidadOperacionesATM + 
					CASE 
						WHEN TM.AcumulaOperacionesATM = 1 THEN 1 
						ELSE 0 
					END,
				SEC.CantidadOperacionesVentanilla = SEC.CantidadOperacionesVentanilla + 
					CASE 
						WHEN TM.AcumulaOperacionesVentana = 1 THEN 1 
						ELSE 0 
					END,
				SEC.SumaCompras = SEC.SumaCompras + 
					CASE WHEN @NombreMovimiento = 'Compra' THEN @Monto ELSE 0 END,
				SEC.CantidadCompras = SEC.CantidadCompras +
					CASE WHEN @NombreMovimiento = 'Compra' THEN 1 ELSE 0 END,
				SEC.SumaRetiros = SEC.SumaRetiros + 
					CASE WHEN @NombreMovimiento = 'Retiro' THEN @Monto ELSE 0 END,
				SEC.CantidadRetiros = SEC.CantidadRetiros + 
					CASE WHEN @NombreMovimiento IN ('Retiro en Ventana', 
					'Retiro en ATM') THEN 1 ELSE 0 END,
				SEC.SumaCreditos = SEC.SumaCreditos + 
					CASE WHEN TM.Accion = 'Credito' THEN @Monto ELSE 0 END,
				SEC.SumaDebitos = SEC.SumaDebitos + 
					CASE WHEN TM.Accion = 'Debito' THEN @Monto ELSE 0 END
			FROM SubEstadoCuenta SEC
				INNER JOIN TM ON TM.Nombre = @NombreMovimiento
				INNER JOIN TCA ON TCA.id = @idTC AND SEC.idTCA = TCA.id
			WHERE DATEDIFF(MONTH, @FechaMovimiento, SEC.FechaCorte) BETWEEN 0 AND 1;
		END
		SET @Contador = @Contador + 1;
	END
END;
GO
