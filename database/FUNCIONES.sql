--FUNCIONES 


--OBTENER LA EDAD DE UN TH
CREATE FUNCTION dbo.ObtenerEdadTarjetahabiente
(
    @idTH INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Edad INT;
    
    SELECT @Edad = DATEDIFF(YEAR, FechaNacimiento, GETDATE())
    FROM dbo.TH
    WHERE id = @idTH;

    RETURN @Edad;
END;
GO

SELECT * FROM TH
SELECT dbo.ObtenerEdadTarjetahabiente(1) AS Edad;


--CALCULA EL SALDO DISPONIBLE 
CREATE FUNCTION dbo.CalcularSaldoDisponible
(
    @idTCM INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @SaldoDisponible MONEY;

    SELECT @SaldoDisponible = (LimiteCredito - SaldoActual)
    FROM dbo.TCM
    INNER JOIN dbo.EstadoCuenta ON TCM.id = EstadoCuenta.idTCM
    WHERE TCM.id = @idTCM;

    RETURN @SaldoDisponible;
END;
GO

SELECT dbo.CalcularSaldoDisponible(1) AS SaldoDisponible;

--VER SI UNA TARJETA ES ACTIVA
CREATE FUNCTION dbo.EsTarjetaActiva
(
    @idTF INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @EsActiva BIT;

    SELECT @EsActiva = EsActiva
    FROM dbo.TF
    WHERE id = @idTF;

    RETURN @EsActiva;
END;
GO


SELECT * FROM TF
SELECT dbo.EsTarjetaActiva(321) AS EsActiva;
