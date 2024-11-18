USE [sistemaTarjetaCredito]
GO

CREATE TRIGGER [dbo].[trInsertTCM]
	ON [dbo].[TCM]
	AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	--INSERTA UN ESTADO DE CUENTA POR CADA TARJETA NUEVA
	INSERT INTO sistemaTarjetaCredito.dbo.EstadoCuenta (
	idTCM,
	FechaCorte,
	SaldoActual,
	PagoContratado,
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
		I.id,
		DATEADD(MONTH, 1, I.FechaCreacion),
		0,
		0,
		0,
		DATEADD(DAY, 10, DATEADD(DAY, 10, I.FechaCreacion)),
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	FROM inserted I;
END
GO

CREATE TRIGGER [dbo].[trInsertTCA]
	ON [dbo].[TCA]
	AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	--INSERTA UN ESTADO DE CUENTA POR CADA TARJETA NUEVA
	INSERT INTO  [dbo].[SubEstadoCuenta]
           ([idTCA]
		   ,[FechaCorte]
           ,[CantidadOperaciones]
           ,[CantidadOperacionesATM]
           ,[SumaCompras]
           ,[SumaRetiros]
           ,[CantidadRetiros]
           ,[SumaCreditos]
           ,[SumaDebitos])
	SELECT
		I.id
		,DATEADD(MONTH, 1, T.FechaCreacion)
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
	FROM inserted I
	JOIN TCM T ON T.id = I.id;
END
GO
