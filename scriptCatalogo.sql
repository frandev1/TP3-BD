USE [sistemaTarjetaCredito]
GO

DECLARE @XmlData XML;
SELECT @XmlData = CONVERT(XML,BULKColumn)
FROM OPENROWSET(BULK 'C:\TEC\BasesDatos1\TP3-BD\CatalogosFinal.xml', SINGLE_CLOB) AS x;

-- Insertar datos en TTCM
INSERT INTO TTCM (Nombre)
SELECT 
    T.C.value('@Nombre', 'VARCHAR(50)')
FROM 
    @XmlData.nodes('/root/TTCM/TTCM') AS T(C);

-- Insertar datos en TRN
INSERT INTO TRN (Nombre, Tipo)
SELECT 
    T.C.value('@Nombre', 'VARCHAR(50)'),
    T.C.value('@tipo', 'VARCHAR(50)')
FROM 
    @XmlData.nodes('/root/TRN/TRN') AS T(C);

-- Insertar datos en RN
INSERT INTO RN (Nombre, idTTCM, idTRN, Valor)
SELECT 
    T.C.value('@Nombre', 'VARCHAR(100)') AS Nombre,
    TTCM.id AS idTTCM,
    TRN.id AS idTRN,
    T.C.value('@Valor', 'VARCHAR(32)') AS Valor
FROM 
    @XmlData.nodes('/root/RN/RN') AS T(C)
JOIN 
    TTCM ON TTCM.Nombre = T.C.value('@TTCM', 'VARCHAR(50)')
JOIN 
    TRN ON TRN.Nombre = T.C.value('@TipoRN', 'VARCHAR(50)');

-- Insertar datos en MIT
INSERT INTO MIT (Nombre)
SELECT 
    M.C.value('@Nombre', 'NVARCHAR(50)') AS Nombre
FROM 
    @XmlData.nodes('/root/MIT/MIT') AS M(C);

-- Insertar datos en TM
INSERT INTO TM (Nombre, Accion, Acumula_Operacion_ATM, Acumula_Operacion_Ventana)
    SELECT 
        T.C.value('@Nombre', 'VARCHAR(50)'),
        T.C.value('@Accion', 'VARCHAR(50)'),
        T.C.value('@Acumula_Operacion_ATM', 'VARCHAR(2)'),
        T.C.value('@Acumula_Operacion_Ventana', 'VARCHAR(2)')
    FROM 
        @XmlData.nodes('/root/TM/TM') AS T(C); 
	
-- Insetar datos en UA
INSERT INTO UA (Nombre, Password)
	SELECT 
		T.C.value('@Nombre', 'VARCHAR(50)'),
		T.C.value('@Password', 'VARCHAR(50)')
	FROM 
		@XmlData.nodes('/root/UA/Usuario') AS T(C);

-- Insertar datos en TMIC
INSERT INTO TMIC (Nombre)
	SELECT 
		T.C.value('@nombre', 'VARCHAR(64)')
	FROM 
		@XmlData.nodes('/root/TMIC/TMIC') AS T(C);


-- Insertar datos en TMIM
INSERT INTO TMIM (Nombre)
	SELECT 
		T.C.value('@nombre', 'VARCHAR(64)')
	FROM 
		@XmlData.nodes('/root/TMIM/TMIM') AS T(C);

-- Borrar todo el contenido de las tablas
USE [sistemaTarjetaCredito]
GO;
-- Desactivar restricciones de claves foráneas
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Eliminar todos los registros de cada tabla
EXEC sp_MSforeachtable 'DELETE FROM ?';

-- Activar nuevamente las restricciones de claves foráneas
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';

--- Revisar inserción
SELECT * FROM TTCM
SELECT * FROM TRN
SELECT * FROM RN
SELECT * FROM MIT
SELECT * FROM TM
SELECT * FROM UA
SELECT * FROM TMIC
SELECT * FROM TMIM