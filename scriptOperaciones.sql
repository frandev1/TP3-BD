USE [sistemaTarjetaCredito]
GO

DECLARE @XmlData XML;

-- Cargar el XML desde el archivo en la variable
SELECT @XmlData = CONVERT(XML, BULKColumn)
FROM OPENROWSET(BULK 'C:\Users\maike\Desktop\TP3\TP3-BD-main\OperacionesCompleto.xml', SINGLE_BLOB) AS x;

-- Insertar datos en la tabla TH
INSERT INTO TH (Nombre, ValorDocIdentidad, FechaNacimiento, NombreUsuario, Password)
SELECT 
    T.C.value('@Nombre', 'NVARCHAR(50)'),
    T.C.value('@ValorDocIdentidad', 'NVARCHAR(20)'),
    T.C.value('@FechaNacimiento', 'DATE'),
    T.C.value('@NombreUsuario', 'NVARCHAR(50)'),
    T.C.value('@Password', 'NVARCHAR(50)')
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTH/NTH') AS T(C);

SELECT * FROM TH

-- Insertar datos en la tabla TCM
INSERT INTO TCM (Codigo, idTTCM, LimiteCredito, idTH, Saldo)
SELECT 
    T.C.value('@Codigo', 'NVARCHAR(20)'),
    TTCM.id AS idTTCM, 
    T.C.value('@LimiteCredito', 'DECIMAL(18,2)'),
    TH.id AS idTH,
	0
	
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTCM/NTCM') AS T(C)
    JOIN TTCM ON TTCM.Nombre = T.C.value('@TipoTCM', 'NVARCHAR(50)')
    JOIN TH ON TH.ValorDocIdentidad = T.C.value('@TH', 'NVARCHAR(20)');

SELECT * FROM TCM


-- Insertar datos en la tabla TCA
INSERT INTO TCA (Codigo, idTCM, idTH)
SELECT 
    T.C.value('@CodigoTCA', 'NVARCHAR(20)'), -- Código de TCA
    TCM.id AS idTCM, -- id de TCM
    TH.id AS idTH    -- id de TH
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTCA/NTCA') AS T(C)
    JOIN TCM ON TCM.Codigo = T.C.value('@CodigoTCM', 'NVARCHAR(20)') -- Usamos Codigo para hacer la relación con TCM
    JOIN TH ON TH.ValorDocIdentidad = T.C.value('@TH', 'NVARCHAR(20)'); -- Relación con TH usando ValorDocIdentidad


SELECT * FROM TCA

-- Insertar datos en la tabla TF
INSERT INTO TF (Codigo, idTCM, FechaVencimiento, CCV, EsActiva)
SELECT 
    T.C.value('@Codigo', 'NVARCHAR(20)'),       -- Código de la tarjeta
    TCA.id AS idTCM,                            -- idTCM obtenido a partir de TCA
    CONVERT(DATE, '01/' + T.C.value('@FechaVencimiento', 'VARCHAR(10)'), 103), -- Formato de fecha
    T.C.value('@CCV', 'NVARCHAR(4)'),           -- CCV de la tarjeta
    1                                           -- Tarjetas activas
FROM 
    @XmlData.nodes('/root/fechaOperacion/NTF/NTF') AS T(C)
    JOIN TCA ON TCA.Codigo = T.C.value('@TCAsociada', 'NVARCHAR(20)'); -- Join con TCA usando Codigo para obtener idTCM


SELECT * FROM TF



-- Insertar datos en la tabla Movimiento
INSERT INTO Movimiento (Nombre, idTF, FechaMovimiento, Monto, Descripcion, Referencia)
SELECT 
    T.C.value('@Nombre', 'NVARCHAR(50)'),
    (SELECT id FROM TF WHERE Codigo = T.C.value('@TF', 'NVARCHAR(20)')),
    T.C.value('@FechaMovimiento', 'DATE'),
    T.C.value('@Monto', 'DECIMAL(18,2)'),
    T.C.value('@Descripcion', 'NVARCHAR(100)'),
    T.C.value('@Referencia', 'NVARCHAR(10)')
FROM 
    @XmlData.nodes('/root/fechaOperacion/Movimiento/Movimiento') AS T(C);

SELECT * FROM TF