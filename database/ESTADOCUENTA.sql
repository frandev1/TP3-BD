ALTER PROCEDURE ProcesarEstadoCuenta
    @idTCM INT,             -- ID de la cuenta a procesar
    @FechaInicioMes DATE    -- Fecha de inicio del mes a procesar
AS
BEGIN
    SET NOCOUNT ON;

    -- Calcular la fecha final del mes
    DECLARE @FechaFinMes DATE = EOMONTH(@FechaInicioMes);

    -- Paso 1: Apertura del estado de cuenta para el mes
    IF NOT EXISTS (SELECT 1 FROM EstadoCuenta WHERE idTCM = @idTCM AND FechaCorte = @FechaInicioMes)
    BEGIN
        -- Asumir saldo inicial como 0 si no se puede calcular
        DECLARE @SaldoInicial DECIMAL(18, 2) = 0;

        -- Si el saldo inicial puede calcularse a partir de otro estado de cuenta
        SELECT TOP 1 @SaldoInicial = SaldoActual
        FROM EstadoCuenta
        WHERE idTCM = @idTCM
        ORDER BY FechaCorte DESC;

        INSERT INTO EstadoCuenta (
            idTCM,
            FechaCorte,
            SaldoActual,
            PagoContratado,
            PagoMinimo,
            FechaPago,
            InteresesCorrientes,
            InteresesMoratorios,
            CantidadOperaciones,
            CantidadOperacionesMes,
            SumaPagosAntesFecha,
            SumaPagosMes,
            CantidadPagosMes,
            CantidadCompras,
            SumaCompras,
            CantidadRetiros,
            SumaRetiros,
            CantidadCreditos,
            SumaCreditos,
            CantidadDebitos,
            SumaDebitos
        )
        SELECT 
            id AS idTCM,
            @FechaInicioMes AS FechaCorte,
            @SaldoInicial AS SaldoActual,            -- Utilizar el saldo inicial del estado de cuenta previo o 0
            0 AS PagoContratado,
            LimiteCredito * 0.1 AS PagoMinimo,       -- Ejemplo: 10% del límite de crédito como mínimo
            @FechaFinMes AS FechaPago,              -- Fecha de fin del mes como fecha de pago
            0 AS InteresesCorrientes,
            0 AS InteresesMoratorios,
            0 AS CantidadOperaciones,
            0 AS CantidadOperacionesMes,
            0 AS SumaPagosAntesFecha,
            0 AS SumaPagosMes,
            0 AS CantidadPagosMes,
            0 AS CantidadCompras,
            0 AS SumaCompras,
            0 AS CantidadRetiros,
            0 AS SumaRetiros,
            0 AS CantidadCreditos,
            0 AS SumaCreditos,
            0 AS CantidadDebitos,
            0 AS SumaDebitos
        FROM TCM
        WHERE id = @idTCM;
    END;

    -- Paso 2: Procesar los movimientos del mes y actualizar el estado de cuenta
    UPDATE EC
    SET 
        EC.SaldoActual = EC.SaldoActual + ISNULL(M.Monto, 0), -- Actualizar saldo con el monto del movimiento
        EC.CantidadOperaciones = EC.CantidadOperaciones + 1, -- Incrementar operaciones totales
        EC.CantidadOperacionesMes = EC.CantidadOperacionesMes + 1, -- Incrementar operaciones del mes
        EC.SumaCompras = EC.SumaCompras + CASE WHEN M.Nombre = 'Compra' THEN M.Monto ELSE 0 END, -- Acumular compras
        EC.CantidadCompras = EC.CantidadCompras + CASE WHEN M.Nombre = 'Compra' THEN 1 ELSE 0 END, -- Contar compras
        EC.SumaRetiros = EC.SumaRetiros + CASE WHEN M.Nombre LIKE 'Retiro%' THEN M.Monto ELSE 0 END, -- Acumular retiros
        EC.CantidadRetiros = EC.CantidadRetiros + CASE WHEN M.Nombre LIKE 'Retiro%' THEN 1 ELSE 0 END, -- Contar retiros
        EC.SumaPagosMes = EC.SumaPagosMes + CASE WHEN M.Nombre LIKE 'Pago%' THEN M.Monto ELSE 0 END, -- Acumular pagos
        EC.CantidadPagosMes = EC.CantidadPagosMes + CASE WHEN M.Nombre LIKE 'Pago%' THEN 1 ELSE 0 END -- Contar pagos
    FROM EstadoCuenta EC
    INNER JOIN TCM ON EC.idTCM = TCM.id
    INNER JOIN TF ON TF.CodigoTC = TCM.Codigo -- Relación correcta entre TCM y TF
    INNER JOIN Movimiento M ON M.idTF = TF.id -- Relación correcta entre Movimiento y TF
    WHERE 
        M.FechaMovimiento BETWEEN @FechaInicioMes AND @FechaFinMes -- Movimientos del mes
        AND TCM.id = @idTCM; -- Filtrar por la cuenta específica

    -- Paso 3: Calcular los intereses y cargos del mes
    UPDATE EC
    SET
        EC.InteresesCorrientes = EC.SaldoActual * 0.02, -- Intereses corrientes (ejemplo: 2%)
        EC.InteresesMoratorios = CASE 
                                    WHEN EC.SaldoActual > EC.PagoMinimo THEN (EC.SaldoActual - EC.PagoMinimo) * 0.05
                                    ELSE 0
                                 END -- Intereses moratorios (ejemplo: 5% si no se cubre el mínimo)
    FROM EstadoCuenta EC
    WHERE EC.idTCM = @idTCM;

    -- Paso 4: Mostrar el estado de cuenta actualizado
    SELECT * 
    FROM EstadoCuenta
    WHERE idTCM = @idTCM;

    PRINT 'Estado de cuenta procesado correctamente.';
END;
GO




EXEC ProcesarEstadoCuenta 
    @idTCM = 1,             -- ID de la cuenta
    @FechaInicioMes = '2024-02-01'; -- Fecha de inicio del mes

