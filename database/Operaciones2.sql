USE [sistemaTarjetaCredito]
GO

DECLARE @XmlData XML;

-- Cargar el xml
SELECT @XmlData = CONVERT(XML, BULKColumn)
FROM OPENROWSET(BULK 'C:\Users\MAIKEL\Desktop\TAREA PROGRAMADA 3\TP3-BD\OperacionesFinal.xml', SINGLE_CLOB) AS x;

DECLARE @FechaActual DATE;
DECLARE @Contador INT;
DECLARE @LargoFecha INT;

DECLARE @Fecha TABLE(
    id INT IDENTITY(1,1),
    Fecha DATE NOT NULL
)

INSERT INTO @Fecha (Fecha)
SELECT DISTINCT 
    T.C.value('@Fecha', 'DATE') AS Fecha
FROM 
    @XmlData.nodes('/root/fechaOperacion') AS T(C);

SELECT @LargoFecha = (SELECT COUNT(*) FROM @XmlData.nodes('/root/fechaOperacion') AS x1(Datos));
SET @Contador = 1;

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

WHILE @Contador <= @LargoFecha
BEGIN
    SELECT @FechaActual = Fecha FROM @Fecha WHERE id = @Contador;
    PRINT 'Procesando fecha: ' + CONVERT(VARCHAR, @FechaActual);

    -- Inserción en tabla TH (ejemplo)
    INSERT INTO TH (Nombre, DocumentoIdentidad, FechaNacimiento, NombreUsuario, Password)
    SELECT 
        T.C.value('@Nombre', 'VARCHAR(50)'),
        T.C.value('@ValorDocIdentidad', 'VARCHAR(20)'),
        T.C.value('@FechaNacimiento', 'DATE'),
        T.C.value('@NombreUsuario', 'VARCHAR(50)'),
        T.C.value('@Password', 'VARCHAR(50)')
    FROM 
        @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
        CROSS APPLY Fecha.C.nodes('NTH/NTH') AS T(C)
    WHERE 
        Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

    -- Inserción en TCM basada en la fecha actual
    INSERT INTO TCM (Codigo, idTTCM, LimiteCredito, idTH, FechaCreacion)
    SELECT 
        T.C.value('@Codigo', 'VARCHAR(32)') AS Codigo,          -- Código de la tarjeta de crédito
        TTCM.id AS idTTCM,                                      -- ID del tipo de tarjeta
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
    INSERT INTO TF (Codigo, CodigoTC, FechaVencimiento, CCV, EsActiva, FechaCreacion)
    SELECT
        T.C.value('@Codigo', 'VARCHAR(64)') AS Codigo,
        T.C.value('@TCAsociada', 'VARCHAR(64)') AS CodigoTC,
        CONVERT(DATE, '01/' + T.C.value('@FechaVencimiento', 'VARCHAR(10)'), 103) AS FechaVencimiento,
        T.C.value('@CCV', 'VARCHAR(4)') AS CCV,
        1 AS EsActiva,
        Fecha.C.value('@Fecha', 'DATE') AS FechaCreacion
    FROM 
        @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
        CROSS APPLY Fecha.C.nodes('NTF/NTF') AS T(C)
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
			)
		FROM @RRP RRP
		WHERE Codigo = RRP.TF AND RRP.FechaReporte = @FechaActual

		PRINT 'Datos de RP insertados para la fecha: ' + CONVERT(VARCHAR, @FechaActual);
    END
    ELSE
    BEGIN
        PRINT 'No se encontraron datos de RP para la fecha: ' + CONVERT(VARCHAR, @FechaActual);
    END;
        
    INSERT INTO Movimiento (Nombre, idTF, FechaMovimiento, Monto, Descripcion, Referencia)
    SELECT
        T.C.value('@Nombre', 'VARCHAR(50)'),
        TF.id AS idTF,
        T.C.value('@FechaMovimiento', 'DATE'),
        T.C.value('@Monto', 'MONEY'),
        T.C.value('@Descripcion', 'VARCHAR(64)'),
        T.C.value('@Referencia', 'VARCHAR(64)')
    FROM 
        @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
        CROSS APPLY Fecha.C.nodes('Movimiento/Movimiento') AS T(C)
        JOIN TF ON TF.Codigo = T.C.value('@TF', 'VARCHAR(20)') -- Join con TCA usando Codigo para obtener idTF
	WHERE Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

    SET @Contador = @Contador + 1;
END;

-- Verificar si el bucle terminó
PRINT 'Proceso completado.';


USE [sistemaTarjetaCredito]
GO


SELECT * FROM TH;
SELECT * FROM TCM;
SELECT * FROM TCA;
SELECT * FROM TF;
SELECT * FROM MIT;
SELECT * FROM Movimiento;
SELECT * FROM EstadoCuenta;
SELECT * FROM SubEstadoCuenta;

-- EXEC ProcesarRoboPerdidaXML @XmlData;

-- ALTER PROCEDURE ProcesarRoboPerdidaXML
--     @XMLData XML -- Pasamos la variable como parámetro
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     -- Verificar que el XML contiene datos válidos
--     IF @XMLData IS NULL
--     BEGIN
--         PRINT 'El XML está vacío o no fue proporcionado.';
--         RETURN;
--     END

--     -- Insertar los datos del XML en la tabla RRP
--     INSERT INTO RRP (TF, Razon, FechaReporte)
--     SELECT 
--         T.c.value('@TF', 'BIGINT') AS TF,
--         T.c.value('@Razon', 'NVARCHAR(50)') AS Razon,
--         TRY_CONVERT(DATE, F.c.value('@Fecha', 'NVARCHAR(10)'), 111) AS FechaReporte -- Usar TRY_CONVERT para manejar errores
--     FROM @XMLData.nodes('/root/fechaOperacion') AS F(c) -- Nodo que contiene la fecha
--     CROSS APPLY F.c.nodes('RenovacionRoboPerdida/RRP') AS T(c);

--     -- Verificar si se insertaron filas
--     IF @@ROWCOUNT = 0
--     BEGIN
--         PRINT 'No se insertaron filas en la tabla RRP. Verifique el XML.';
--         RETURN;
--     END

--     -- Actualizar las tarjetas en la tabla TF para invalidarlas
--     UPDATE TF
--     SET 
--         EsActiva = 0, -- Desactivar la tarjeta
--         idMotivoInvalidacion = CASE 
--             WHEN R.Razon = 'Robo' THEN 1 -- Asignar motivo "Robo"
--             WHEN R.Razon = 'Perdida' THEN 2 -- Asignar motivo "Perdida"
--             ELSE NULL
--         END
--     FROM TF
--     INNER JOIN RRP R ON TF.Codigo = R.TF; -- Relacionar por el código de tarjeta

--     PRINT 'Las tarjetas reportadas han sido procesadas correctamente.';
-- END;
-- GO
