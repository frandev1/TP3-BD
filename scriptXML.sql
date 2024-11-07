USE [sistemaTarjetaCredito]
GO

DECLARE @XmlData XML;
SELECT @XmlData = CONVERT(XML,�BULKColumn)
FROM OPENROWSET(BULK 'C:\Users\maike\Desktop\TP3\TP3-BD-main\Catalogos.xml', SINGLE_BLOB) AS x;


EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries',�1;
RECONFIGURE;


-- Insertar datos en TTCM
INSERT INTO TTCM (Nombre)
SELECT 
    T.C.value('@Nombre', 'NVARCHAR(50)')
FROM 
    @XmlData.nodes('/root/TTCM/TTCM') AS T(C);

-- Insertar datos en TRN
INSERT INTO TRN (Nombre, Tipo)
SELECT 
    T.C.value('@Nombre', 'NVARCHAR(50)'),
    T.C.value('@tipo', 'NVARCHAR(50)')
FROM 
    @XmlData.nodes('/root/TRN/TRN') AS T(C);

-- Insertar datos en RN
INSERT INTO RN (Nombre, idTTCM, idTRN, Valor)
SELECT 
    T.C.value('@Nombre', 'NVARCHAR(100)') AS Nombre,
    TTCM.id AS idTTCM,
    TRN.id AS idTRN,
    T.C.value('@Valor', 'DECIMAL(18,2)') AS Valor
FROM 
    @XmlData.nodes('/root/RN/RN') AS T(C)
JOIN 
    TTCM ON TTCM.Nombre = T.C.value('@TTCM', 'NVARCHAR(50)')
JOIN 
    TRN ON TRN.Nombre = T.C.value('@TipoRN', 'NVARCHAR(50)');

-- Insertar datos en MIT
INSERT INTO MIT (Nombre)
SELECT 
    M.C.value('@Nombre', 'NVARCHAR(50)') AS Nombre
FROM 
    @XmlData.nodes('/root/MIT/MIT') AS M(C);

-- Insertar datos en TM
INSERT INTO TM (Nombre, Accion, Acumula_Operacion_ATM, Acumula_Operacion_Ventana)
    SELECT 
        T.C.value('@Nombre', 'NVARCHAR(50)'),
        T.C.value('@Accion', 'NVARCHAR(50)'),
        T.C.value('@Acumula_Operacion_ATM', 'NVARCHAR(2)'),
        T.C.value('@Acumula_Operacion_Ventana', 'NVARCHAR(2)')
    FROM 
        @XmlData.nodes('/root/TM/TM') AS T(C); 
	
-- Insetar datos en UA
INSERT INTO UA (Nombre, Password)
	SELECT 
		T.C.value('@Nombre', 'NVARCHAR(50)'),
		T.C.value('@Password', 'NVARCHAR(50)')
	FROM 
		@XmlData.nodes('/UA/Usuario') AS T(C);

-- Insertar datos en TMIC
INSERT INTO TMIC (Nombre)
	SELECT 
		T.C.value('@Nombre', 'NVARCHAR(50)')
	FROM 
		@XmlData.nodes('/root/TMIC/TMIC') AS T(C);


-- Insertar datos en TMIM
INSERT INTO TMIC (Nombre)
	SELECT 
		T.C.value('@Nombre', 'NVARCHAR(50)')
	FROM 
		@XmlData.nodes('/root/TMIM/TMIM') AS T(C);
