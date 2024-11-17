USE [sistemaTarjetaCredito]
GO

DECLARE @XmlData XML;

-- Cargar el xml
SELECT @XmlData = CONVERT(XML, BULKColumn)
FROM OPENROWSET(BULK 'C:\TEC\BasesDatos1\TP3-BD\OperacionesFinal.xml', SINGLE_CLOB) AS x;

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
        FROM @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
        WHERE Fecha.C.value('@Fecha', 'DATE') = @FechaActual
        AND EXISTS (
            SELECT 1
            FROM Fecha.C.nodes('RenovacionRoboPerdida/RRP') AS RRP(C)
        )
        )
    BEGIN
        -- Inserción en la tabla MIT
        INSERT INTO MIT (Nombre)
        SELECT
            T.C.value('@Razon', 'VARCHAR(20)') -- Razón de la renovación (Robo o Pérdida)
        FROM 
            @XmlData.nodes('/root/fechaOperacion') AS Fecha(C)
            CROSS APPLY Fecha.C.nodes('RenovacionRoboPerdida/RRP') AS T(C)
        WHERE Fecha.C.value('@Fecha', 'DATE') = @FechaActual;

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

SELECT * FROM TH;
SELECT * FROM TCM;
SELECT * FROM TCA;
SELECT * FROM TF;
SELECT * FROM MIT;
SELECT * FROM Movimiento;