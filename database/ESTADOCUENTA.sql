USE [sistemaTarjetaCredito]
GO

SELECT * FROM TCM
SELECT * FROM Movimiento
SELECT * FROM TF
SELECT * FROM TTCM


CREATE TABLE TasaInteres (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idTTCM INT NOT NULL,
    TasaInteresesCorrienteMensual DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (idTTCM) REFERENCES TTCM(id)
);


INSERT INTO TasaInteres (idTTCM, TasaInteresesCorrienteMensual)
VALUES
(1, 2.5),  -- Corporativo: 2.5% mensual
(2, 3.0),  -- Platino: 3.0% mensual
(3, 3.5);  -- Oro: 3.5% mensual



ALTER PROCEDURE GenerarEstadoCuentaMensual
AS
BEGIN
    DECLARE @FechaCorte DATE = GETDATE();
    DECLARE @TarjetaID INT;
    DECLARE @TasaInteresesCorrienteMensual DECIMAL(10, 2);
    DECLARE @SaldoActual MONEY;
    DECLARE @InteresesCorrientes MONEY;
    DECLARE @InteresesMoratorios MONEY;
    DECLARE @SumaDebitos MONEY;
    DECLARE @SumaCreditos MONEY;
    DECLARE @PagoContratado MONEY = 0; -- Valor por defecto
    DECLARE @PagoMinimo MONEY = 0; -- Valor por defecto
    DECLARE @FechaPago DATE = GETDATE(); -- Valor predeterminado
    DECLARE @CantidadOperacionesATM INT = 0;
    DECLARE @CantidadOperacionesVentanilla INT = 0;
    DECLARE @SumaPagosAntesFecha MONEY = 0;
    DECLARE @SumaPagosMes MONEY = 0;
    DECLARE @CantidadPagosMes INT = 0;
    DECLARE @CantidadCompras INT = 0;
    DECLARE @CantidadRetiros INT = 0;
    DECLARE @SumaCompras MONEY = 0;
    DECLARE @SumaRetiros MONEY = 0;
    DECLARE @CantidadCreditos INT = 0;
    DECLARE @CantidadDebitos INT = 0;

    -- Cursor para iterar sobre todas las tarjetas activas
    DECLARE TarjetasCursor CURSOR FOR
    SELECT TCM.id, TI.TasaInteresesCorrienteMensual
    FROM TCM
    JOIN TasaInteres TI ON TCM.idTTCM = TI.idTTCM
    
    OPEN TarjetasCursor;
    FETCH NEXT FROM TarjetasCursor INTO @TarjetaID, @TasaInteresesCorrienteMensual;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calcular saldo actual sumando los movimientos hasta la fecha de corte
        SELECT @SaldoActual = ISNULL(SUM(Monto), 0)
        FROM Movimiento
        WHERE idTF IN (
            SELECT TF.id
            FROM TF
            WHERE TF.CodigoTC = (SELECT Codigo FROM TCM WHERE id = @TarjetaID)
        ) AND FechaMovimiento <= @FechaCorte;

        -- Calcular intereses corrientes
        IF @SaldoActual > 0
        BEGIN
            SET @InteresesCorrientes = @SaldoActual * (@TasaInteresesCorrienteMensual / 100) / 30;
        END
        ELSE
        BEGIN
            SET @InteresesCorrientes = 0;
        END

        -- Calcular otros valores
        SET @InteresesMoratorios = 0; -- Agregar lógica si aplica
        SET @SumaDebitos = ISNULL((
            SELECT SUM(Monto)
            FROM Movimiento
            WHERE idTF IN (
                SELECT TF.id
                FROM TF
                WHERE TF.CodigoTC = (SELECT Codigo FROM TCM WHERE id = @TarjetaID)
            ) AND Monto < 0 AND FechaMovimiento <= @FechaCorte
        ), 0);

        SET @SumaCreditos = ISNULL((
            SELECT SUM(Monto)
            FROM Movimiento
            WHERE idTF IN (
                SELECT TF.id
                FROM TF
                WHERE TF.CodigoTC = (SELECT Codigo FROM TCM WHERE id = @TarjetaID)
            ) AND Monto > 0 AND FechaMovimiento <= @FechaCorte
        ), 0);

        -- Insertar los datos en la tabla EstadoCuenta
        INSERT INTO EstadoCuenta (
            idTCM, FechaCorte, SaldoActual, PagoContratado, 
            PagoMinimo, FechaPago, InteresesCorrientes, InteresesMoratorios, 
            CantidadOperacionesATM, CantidadOperacionesVentanilla, SumaPagosAntesFecha, 
            SumaPagosMes, CantidadPagosMes, CantidadCompras, CantidadRetiros, 
            SumaCompras, SumaRetiros, CantidadCreditos, SumaCreditos, 
            CantidadDebitos, SumaDebitos
        )
        VALUES (
            @TarjetaID, @FechaCorte, @SaldoActual, @PagoContratado, 
            @PagoMinimo, @FechaPago, @InteresesCorrientes, @InteresesMoratorios, 
            @CantidadOperacionesATM, @CantidadOperacionesVentanilla, @SumaPagosAntesFecha, 
            @SumaPagosMes, @CantidadPagosMes, @CantidadCompras, @CantidadRetiros, 
            @SumaCompras, @SumaRetiros, @CantidadCreditos, @SumaCreditos, 
            @CantidadDebitos, @SumaDebitos
        );

        -- Pasar a la siguiente tarjeta
        FETCH NEXT FROM TarjetasCursor INTO @TarjetaID, @TasaInteresesCorrienteMensual;
    END;

    CLOSE TarjetasCursor;
    DEALLOCATE TarjetasCursor;

    PRINT 'Proceso de generación de estados de cuenta completado.';
END;




EXEC GenerarEstadoCuentaMensual;
SELECT * FROM EstadoCuenta
EXEC sp_help 'EstadoCuenta';
