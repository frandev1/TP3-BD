--VISTAS

--Tarjetas físicas activas con sus detalles básicos.
CREATE VIEW dbo.VistaTarjetasFisicasActivas
AS
SELECT 
    TF.id AS TarjetaFisicaID,
    TF.Codigo AS NumeroTarjeta,
    TF.CodigoTC AS CodigoTarjetaCredito,
    TF.FechaVencimiento,
    TF.FechaCreacion
FROM dbo.TF
WHERE TF.EsActiva = 1;
GO

SELECT * FROM dbo.VistaTarjetasFisicasActivas;

--Tarjetahabientes y las tarjetas (físicas y de crédito) que tienen asociadas
CREATE VIEW dbo.VistaTarjetahabientesConTarjetas
AS
SELECT 
    TH.id AS TarjetahabienteID,
    TH.Nombre AS NombreTarjetahabiente,
    TH.DocumentoIdentidad,
    TCM.Codigo AS CodigoTarjetaCredito,
    TF.Codigo AS CodigoTarjetaFisica,
    TF.FechaVencimiento,
    TF.EsActiva AS TarjetaFisicaActiva
FROM dbo.TH
LEFT JOIN dbo.TCM ON TH.id = TCM.idTH
LEFT JOIN dbo.TF ON TCM.Codigo = TF.CodigoTC;
GO

SELECT * FROM dbo.VistaTarjetahabientesConTarjetas;