USE [master]
GO
/****** Object:  Database [sistemaTarjetaCredito]    Script Date: 13/11/2024 18:17:01 ******/
CREATE DATABASE [sistemaTarjetaCredito]
GO
USE [sistemaTarjetaCredito]
GO
/****** Object:  Table [dbo].[EstadoCuenta]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EstadoCuenta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTCM] [int] NOT NULL,
	[FechaCorte] [date] NOT NULL,
	[SaldoActual] [decimal](10, 2) NOT NULL,
	[PagoContratado] [decimal](10, 2) NOT NULL,
	[PagoMinimo] [decimal](10, 2) NOT NULL,
	[FechaPago] [date] NOT NULL,
	[InteresesCorrientes] [decimal](10, 2) NOT NULL,
	[InteresesMoratorios] [decimal](10, 2) NOT NULL,
	[CantidadOperaciones] [int] NOT NULL,
	[CantidadOperacionesMes] [int] NOT NULL,
	[SumaPagosAntesFecha] [decimal](10, 2) NOT NULL,
	[SumaPagosMes] [decimal](10, 2) NOT NULL,
	[CantidadPagosMes] [int] NOT NULL,
	[CantidadCompras] [int] NOT NULL,
	[CantidadRetiros] [int] NOT NULL,
	[SumaCompras] [decimal](10, 2) NOT NULL,
	[SumaRetiros] [decimal](10, 2) NOT NULL,
	[CantidadCreditos] [int] NOT NULL,
	[SumaCreditos] [decimal](10, 2) NOT NULL,
	[CantidadDebitos] [int] NOT NULL,
	[SumaDebitos] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MotivoInvalidadacionTarjeta]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MotivoInvalidadacionTarjeta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Movimiento]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Movimiento](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTF] [int] NULL,
	[idTH] [int] NOT NULL,
	[FechaMovimiento] [date] NOT NULL,
	[Monto] [money] NOT NULL,
	[Descripcion] [varchar](64) NOT NULL,
	[Referencia] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReglasNegocio]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReglasNegocio](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTTCM] [int] NOT NULL,
	[idTipoRN] [int] NOT NULL,
	[Valor] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubEstadoCuenta]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubEstadoCuenta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTCA] [int] NOT NULL,
	[CantidadOperaciones] [int] NOT NULL,
	[CantidadOperacionesATM] [int] NOT NULL,
	[SumaCompras] [decimal](10, 2) NOT NULL,
	[SumaRetiros] [decimal](10, 2) NOT NULL,
	[CantidadRetiros] [int] NOT NULL,
	[SumaCreditos] [decimal](10, 2) NOT NULL,
	[SumaDebitos] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TCA]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TCA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTCM] [int] NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[idTH] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TCM]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TCM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[idTTCM] [int] NOT NULL,
	[LimiteCredito] [decimal](10, 2) NOT NULL,
	[idTH] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TF]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TF](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [int] NOT NULL,
	[CodigoTC] [int] NOT NULL,
	[FechaVencimiento] [date] NOT NULL,
	[CCV] [varchar](4) NOT NULL,
	[EsActiva] [bit] NOT NULL,
	[idMotivoInvalidacion] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TH]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TH](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[idTipoDocumentoIdentidad] [int] NOT NULL,
	[DocumentoIdentidad] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMovimientoCorriente]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMovimientoCorriente](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Accion] [varchar](50) NOT NULL,
	[AcumulaOperacionesATM] [bit] NOT NULL,
	[AcumulaOperacionesVentana] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMovimientoIntereses]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMovimientoIntereses](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMovimientoMoratorios]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMovimientoMoratorios](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoReglasNegocio]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoReglasNegocio](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Tipo] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TTCM]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TTCM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UA]    Script Date: 13/11/2024 18:17:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EstadoCuenta]  WITH CHECK ADD FOREIGN KEY([idTCM])
REFERENCES [dbo].[TCM] ([id])
GO
ALTER TABLE [dbo].[Movimiento]  WITH CHECK ADD FOREIGN KEY([idTF])
REFERENCES [dbo].[TF] ([id])
GO
ALTER TABLE [dbo].[Movimiento]  WITH CHECK ADD FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[ReglasNegocio]  WITH CHECK ADD FOREIGN KEY([idTipoRN])
REFERENCES [dbo].[TipoReglasNegocio] ([id])
GO
ALTER TABLE [dbo].[ReglasNegocio]  WITH CHECK ADD FOREIGN KEY([idTTCM])
REFERENCES [dbo].[TTCM] ([id])
GO
ALTER TABLE [dbo].[SubEstadoCuenta]  WITH CHECK ADD FOREIGN KEY([idTCA])
REFERENCES [dbo].[TCA] ([id])
GO
ALTER TABLE [dbo].[TCA]  WITH CHECK ADD FOREIGN KEY([idTCM])
REFERENCES [dbo].[TTCM] ([id])
GO
ALTER TABLE [dbo].[TCA]  WITH CHECK ADD FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[TCM]  WITH CHECK ADD FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[TCM]  WITH CHECK ADD FOREIGN KEY([idTTCM])
REFERENCES [dbo].[TTCM] ([id])
GO
ALTER TABLE [dbo].[TF]  WITH CHECK ADD FOREIGN KEY([idMotivoInvalidacion])
REFERENCES [dbo].[MotivoInvalidadacionTarjeta] ([id])
GO
USE [master]
GO
ALTER DATABASE [sistemaTarjetaCredito] SET  READ_WRITE 
GO
