USE [sistemaTarjetaCredito]
GO

DECLARE @XmlData XML;

-- Cargar el XML desde el archivo en la variable
SELECT @XmlData = CONVERT(XML, BULKColumn)
FROM OPENROWSET(BULK 'C:\Users\MAIKEL\Desktop\TAREA PROGRAMADA 3\TP3-BD\OperacionesFinal.xml', SINGLE_CLOB) AS x;

-- Insertar datos en la tabla TH
INSERT INTO TH (Nombre, DocumentoIdentidad, FechaNacimiento, NombreUsuario, Password)
SELECT 
    T.C.value('@Nombre', 'VARCHAR(50)'),
    T.C.value('@ValorDocIdentidad', 'VARCHAR(20)'),
    T.C.value('@FechaNacimiento', 'DATE'),
    T.C.value('@NombreUsuario', 'VARCHAR(50)'),
    T.C.value('@Password', 'VARCHAR(50)')
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTH/NTH') AS T(C);



-- Insertar datos en la tabla TCM
INSERT INTO TCM (Codigo, idTTCM, LimiteCredito, idTH, Saldo)
SELECT 
    T.C.value('@Codigo', 'VARCHAR(32)'),
    TTCM.id AS idTTCM, 
    T.C.value('@LimiteCredito', 'MONEY'),
    TH.id AS idTH,
	0
	
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTCM/NTCM') AS T(C)
    JOIN TTCM ON TTCM.Nombre = T.C.value('@TipoTCM', 'VARCHAR(50)')
    JOIN TH ON TH.DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(20)');



-- Insertar datos en la tabla TCA
INSERT INTO TCA (idTCM, Codigo, idTH)
SELECT 
    TCM.id AS idTCM, -- id de TCM
	T.C.value('@CodigoTCA', 'VARCHAR(32)'), -- Codigo de TCA
    TH.id AS idTH    -- id de TH
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTCA/NTCA') AS T(C)
    JOIN TCM ON TCM.Codigo = T.C.value('@CodigoTCM', 'VARCHAR(32)') -- Usamos Codigo para hacer la relacion con TCM
    JOIN TH ON TH.DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(32)'); -- Relacion con TH usando ValorDocIdentidad


-- Inserta datos en la tabla TF (Codigo, idTC, FechaVencimiento, CCV, EsActiva, FechaCreacion)
INSERT INTO TF (Codigo, CodigoTC, FechaVencimiento, CCV, EsActiva, FechaCreacion)
SELECT
    T.C.value('@Codigo', 'VARCHAR(64)') AS Codigo,
    T.C.value('@TCAsociada', 'VARCHAR(64)') AS CodigoTC,
    CONVERT(DATE, '01/' + T.C.value('@FechaVencimiento', 'VARCHAR(10)'), 103) AS FechaVencimiento,
    T.C.value('@CCV', 'VARCHAR(4)') AS CCV,
    1 AS EsActiva,
    M.C.value('@FechaMovimiento', 'DATE') AS FechaCreacion -- Usa la FechaMovimiento del XML en lugar de GETDATE()
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTF/NTF') AS T(C)
JOIN 
    @XmlData.nodes('/root/fechaOperacion/Movimiento/Movimiento') AS M(C)
    ON M.C.value('@TF', 'VARCHAR(20)') = T.C.value('@Codigo', 'VARCHAR(20)');

-- Insertar datos en la tabla RP desde el XML
INSERT INTO MIT (Nombre)
SELECT            -- id de la Tarjeta F�sica
    R.C.value('@Razon', 'VARCHAR(20)') -- Raz�n de la renovaci�n (Robo o P�rdida)
FROM 
    @XmlData.nodes('/root/fechaOperacion/RenovacionRoboPerdida/RRP') AS R(C)

-- Insertar datos en la tabla Movimiento
INSERT INTO Movimiento (Nombre, idTF, FechaMovimiento, Monto, Descripcion, Referencia)
SELECT 
    T.C.value('@Nombre', 'VARCHAR(50)'),
    TF.id AS idTF,
    T.C.value('@FechaMovimiento', 'DATE'),
    T.C.value('@Monto', 'MONEY'),
    T.C.value('@Descripcion', 'VARCHAR(64)'),
    T.C.value('@Referencia', 'VARCHAR(64)')
FROM 
    @XmlData.nodes('/root/fechaOperacion/Movimiento/Movimiento') AS T(C)
    JOIN TF ON TF.Codigo = T.C.value('@TF', 'VARCHAR(20)') -- Join con TCA usando Codigo para obtener idTF


SELECT * FROM TH
SELECT * FROM TCM
SELECT * FROM TCA
SELECT * FROM TF
SELECT * FROM MIT
SELECT * FROM Movimiento