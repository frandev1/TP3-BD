USE [sistemaTarjetaCredito]
GO

DECLARE @XmlData XML;

-- Cargar el xml
SELECT @XmlData = CONVERT(XML, BULKColumn)
FROM OPENROWSET(BULK 'C:\TEC\BasesDatos1\TP3-BD\OperacionesFinal.xml', SINGLE_CLOB) AS x;

DECLARE @FechaActual DATE;
DECLARE @UltimaFecha DATE;

DECLARE @Fecha TABLE(
    id INT IDENTITY(1,1),
    Fecha DATE NOT NULL
)

INSERT INTO @Fecha (Fecha)
SELECT DISTINCT 
    T.C.value('@Fecha', 'DATE') AS Fecha
FROM 
    @XmlData.nodes('/root/fechaOperacion') AS T(C);

SELECT
	@FechaActual = MIN(Fecha)
FROM @Fecha

SELECT
	@UltimaFecha = MAX(Fecha)
FROM @Fecha

PRINT 'PRIMERA FECHA:' + CONVERT(VARCHAR, @FechaActual) + ' UltimaFecha:' + CONVERT(VARCHAR, @UltimaFecha)

DECLARE @RRP TABLE(
    id INT IDENTITY(1,1), -- Identificador único
    TF VARCHAR(64) NOT NULL,              -- Código de la tarjeta
    Razon VARCHAR(64) NOT NULL,     -- Razón del reporte (Robo o Perdida)
    FechaReporte DATE NOT NULL -- Fecha del reporte
);

INSERT INTO @RRP (TF, Razon, FechaReporte)
SELECT
    T.C.value('@TF', 'VARCHAR(64)') AS TF,
    T.C.value('@Razon', 'VARCHAR(64)') AS Razon,
    Fecha.C.value('@Fecha', 'DATE') AS FechaReporte
FROM 
    @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
    CROSS APPLY Fecha.C.nodes('RenovacionRoboPerdida/RRP') AS T(C);

WHILE @FechaActual <= @UltimaFecha
BEGIN
    PRINT 'Procesando fecha: ' + CONVERT(VARCHAR, @FechaActual);

	INSERT INTO Usuario (Username, Password, TipoUsuario)
	SELECT
		T.C.value('@NombreUsuario', 'VARCHAR(50)'),
        T.C.value('@Password', 'VARCHAR(50)'),
		0
	FROM
		@XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
        CROSS APPLY Fecha.C.nodes('NTH/NTH') AS T(C)
	WHERE 
        Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

    -- Inserción en tabla TH (ejemplo)
    INSERT INTO TH (Nombre, DocumentoIdentidad, FechaNacimiento, idUsuario)
    SELECT 
        T.C.value('@Nombre', 'VARCHAR(50)'),
        T.C.value('@ValorDocIdentidad', 'VARCHAR(20)'),
        T.C.value('@FechaNacimiento', 'DATE'),
		U.id
    FROM 
        @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
        CROSS APPLY Fecha.C.nodes('NTH/NTH') AS T(C)
		INNER JOIN Usuario U ON U.Username = T.C.value('@NombreUsuario', 'VARCHAR(50)')
			AND U.Password = T.C.value('@Password', 'VARCHAR(50)')
    WHERE 
        Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

    -- Inserción en TCM basada en la fecha actual
    INSERT INTO TCM (Codigo, idTTCM, Saldo, LimiteCredito, idTH, FechaCreacion)
    SELECT 
        T.C.value('@Codigo', 'VARCHAR(32)') AS Codigo,          -- Código de la tarjeta de crédito
        TTCM.id AS idTTCM,                                      -- ID del tipo de tarjeta
		0,
        T.C.value('@LimiteCredito', 'MONEY') AS LimiteCredito,  -- Límite de crédito
        TH.id AS idTH,                                          -- ID del titular
        Fecha.C.value('@Fecha', 'DATE')                                            -- Saldo inicial
    FROM 
        @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)   -- Nodo raíz con fecha de operación
        CROSS APPLY Fecha.C.nodes('NTCM/NTCM') AS T(C)         -- Subnodos de NTCM
        JOIN TTCM ON Nombre = T.C.value('@TipoTCM', 'VARCHAR(50)') -- Relación con TTCM
        JOIN TH ON DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(32)') -- Relación con TH
    WHERE 
        Fecha.C.value('@Fecha', 'DATE') = @FechaActual;      -- Filtro por fecha actual
    
    -- Inserción en TCA
    INSERT INTO TCA (idTCM, Codigo, idTH)
    SELECT 
        TCM.id AS idTCM, -- id de TCM
        T.C.value('@CodigoTCA', 'VARCHAR(32)'), -- Codigo de TCA
        TH.id AS idTH    -- id de TH
    FROM 
        @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
        CROSS APPLY Fecha.C.nodes('NTCA/NTCA') AS T(C)
        JOIN TCM ON TCM.Codigo = T.C.value('@CodigoTCM', 'VARCHAR(32)') -- Usamos Codigo para hacer la relacion con TCM
        JOIN TH ON TH.DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(32)') -- Relacion con TH usando ValorDocIdentidad
	WHERE Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

    -- Inserta datos en la tabla TF (Codigo, idTC, FechaVencimiento, CCV, EsActiva, FechaCreacion)
    INSERT INTO TF (Codigo, idTCM, idTCA, FechaVencimiento, CCV, EsActiva, FechaCreacion)
	SELECT
		T.C.value('@Codigo', 'VARCHAR(64)') AS Codigo, -- Código único de tarjeta
		TCM.id AS idTCM, -- id del TCM si existe
		TCA.id AS idTCA, -- id del TCA si existe
		CONVERT(DATE, '01/' + T.C.value('@FechaVencimiento', 'VARCHAR(10)'), 103) AS FechaVencimiento, -- Fecha en formato correcto
		T.C.value('@CCV', 'VARCHAR(4)') AS CCV, -- CCV de la tarjeta
		1 AS EsActiva, -- Activar por defecto
		Fecha.C.value('@Fecha', 'DATE') AS FechaCreacion -- Fecha de creación
	FROM 
		@XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
		CROSS APPLY Fecha.C.nodes('NTF/NTF') AS T(C)
		LEFT JOIN TCM ON TCM.Codigo = T.C.value('@TCAsociada', 'VARCHAR(64)') -- Relación con TCM
		LEFT JOIN TCA ON TCA.Codigo = T.C.value('@TCAsociada', 'VARCHAR(64)') -- Relación con TCA
	WHERE Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

    
    -- Validar si hay nodos de RenovaciónRoboPerdida para la fecha actual
    IF EXISTS (
        SELECT 1
        FROM @RRP RRP
        WHERE RRP.FechaReporte = @FechaActual
        )
    BEGIN
		UPDATE TF
		SET
			EsActiva = 0,
			idMotivoInvalidacion = (
				SELECT MIT.id
				FROM MIT MIT
				WHERE MIT.Nombre = RRP.Razon
			),
            FechaInvalidacion = @FechaActual
		FROM @RRP RRP
		WHERE Codigo = RRP.TF AND RRP.FechaReporte = @FechaActual

		PRINT 'Datos de RP insertados para la fecha: ' + CONVERT(VARCHAR, @FechaActual);
    END
    ELSE
    BEGIN
        PRINT 'No se encontraron datos de RP para la fecha: ' + CONVERT(VARCHAR, @FechaActual);
    END;

	UPDATE TF
	SET
		EsActiva = 0,
		idMotivoInvalidacion = 3,
		FechaInvalidacion = @FechaActual
	WHERE FechaVencimiento = @FechaActual AND EsActiva = 1

	INSERT INTO Movimiento (
		idTM, 
		idEC, 
		idTF, 
		FechaMovimiento, 
		Monto, 
		Descripcion, 
		Referencia,
		NuevoSaldo
	)
	SELECT
		TM.id AS idTM,
		ISNULL(EC.id, EC_TCA.id) AS idEC, -- Prioriza idEC para TCM, luego para TCA
		TF.id AS idTF,
		T.C.value('@FechaMovimiento', 'DATE') AS FechaMovimiento,
		CAST(T.C.value('@Monto', 'DECIMAL(18,2)') AS MONEY) AS Monto,
		T.C.value('@Descripcion', 'VARCHAR(64)') AS Descripcion,
		T.C.value('@Referencia', 'VARCHAR(64)') AS Referencia,
		0
	FROM 
		@XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
		CROSS APPLY Fecha.C.nodes('Movimiento/Movimiento') AS T(C)
		INNER JOIN TF ON TF.Codigo = T.C.value('@TF', 'VARCHAR(20)') -- Relación con TF
		INNER JOIN TM ON TM.Nombre = T.C.value('@Nombre', 'VARCHAR(50)') -- Relación con TM
		LEFT JOIN EstadoCuenta EC ON EC.idTCM = TF.idTCM 
			AND @FechaActual BETWEEN DATEADD(MONTH, -1, EC.FechaCorte) AND EC.FechaCorte
		LEFT JOIN TCA ON TCA.id = TF.idTCA -- Relación con TCA
		LEFT JOIN EstadoCuenta EC_TCA ON EC_TCA.idTCM = TCA.idTCM 
			AND @FechaActual BETWEEN DATEADD(MONTH, -1, EC_TCA.FechaCorte) AND EC_TCA.FechaCorte
	WHERE 
		Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

	UPDATE EstadoCuenta
		SET
			EstadoCuenta.PagoContado = EC.PagoMinimo,
			EstadoCuenta.InteresesCorrientes = EC.SaldoActual / RN.Valor / 100 / 30
		FROM EstadoCuenta EC
		INNER JOIN TCM ON TCM.id = EC.idTCM
		INNER JOIN RN ON RN.Nombre = 'Tasa de interes corriente'
			AND RN.idTTCM = TCM.idTTCM
		WHERE @FechaActual BETWEEN DATEADD(MONTH, -1, EC.FechaCorte) AND EC.FechaCorte

	UPDATE EstadoCuenta
		SET
			EstadoCuenta.PagoContado = EC.PagoMinimo,
			EstadoCuenta.InteresesMoratorios = EC.SaldoActual / RN.Valor / 100 / 30
		FROM EstadoCuenta EC
		INNER JOIN TCM ON TCM.id = EC.idTCM
		INNER JOIN RN ON RN.Nombre = 'intereses moratorios'
			AND RN.idTTCM = TCM.idTTCM
		WHERE @FechaActual BETWEEN DATEADD(MONTH, -1, EC.FechaCorte) AND EC.FechaCorte

    INSERT INTO EstadoCuenta (
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
        EC.idTCM,
        DATEADD(MONTH, 1, @FechaActual) AS FechaCorte, -- Nueva fecha de corte (1 mes después)
        0, -- Saldo inicial
        EC.PagoMinimo, -- Pago contratado inicial
        0, -- Pago mínimo inicial
        DATEADD(DAY, CAST(RN.Valor AS int), DATEADD(MONTH, 1, @FechaActual)), -- Nueva fecha de pago (10 días después de la fecha de corte)
        0, -- Intereses corrientes iniciales
        0, -- Intereses moratorios iniciales
        0, -- Operaciones ATM iniciales
        0, -- Operaciones ventanilla iniciales
        0, -- Suma de pagos antes de la fecha inicial
        0, -- Suma de pagos del mes inicial
        0, -- Cantidad de pagos inicial
        0, -- Cantidad de compras inicial
        0, -- Cantidad de retiros inicial
        0, -- Suma de compras inicial
        0, -- Suma de retiros inicial
        0, -- Cantidad de créditos inicial
        0, -- Suma de créditos inicial
        0, -- Cantidad de débitos inicial
        0 -- Suma de débitos inicial
    FROM EstadoCuenta EC
    INNER JOIN dbo.TCM TCM ON TCM.id = EC.idTCM
    INNER JOIN dbo.TTCM TTCM ON TCM.idTTCM = TTCM.id
    INNER JOIN dbo.TRN TRN ON TRN.Nombre = 'Cantidad de dias'
    INNER JOIN dbo.RN RN ON RN.idTRN = TRN.id 
        AND RN.idTTCM = TCM.idTTCM
        AND RN.Nombre = 'Cantidad de dias para pago saldo de contado'
    WHERE EC.FechaCorte = @FechaActual;

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
        SEC.idTCA
		, DATEADD(MONTH, 1, @FechaActual)
        , 0
        , 0
        , 0
        , 0
        , 0
        , 0
        , 0
        , 0
    FROM SubEstadoCuenta SEC
	WHERE SEC.FechaCorte = @FechaActual;

    SET @FechaActual = DATEADD(DAY, 1, @FechaActual);
END;

-- Verificar si el bucle terminó
PRINT 'Proceso completado.';


USE [sistemaTarjetaCredito]
GO

SELECT * FROM Usuario;
SELECT * FROM TH;
SELECT * FROM TCM;
SELECT * FROM TCA;
SELECT * FROM TF;
SELECT * FROM Movimiento;
SELECT * FROM EstadoCuenta;
SELECT * FROM SubEstadoCuenta;