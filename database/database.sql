USE [master]
GO
/****** Object:  Database [sistemaTarjetaCredito]    Script Date: 15/11/2024 20:03:02 ******/
CREATE DATABASE [sistemaTarjetaCredito]
GO
USE [sistemaTarjetaCredito]
GO
/****** Object:  Table [dbo].[DBError]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBError](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ErrorUserName] [nvarchar](50) NOT NULL,
	[ErrorNumber] [int] NOT NULL,
	[ErrorState] [nvarchar](50) NOT NULL,
	[ErrorSeverity] [nvarchar](50) NOT NULL,
	[ErrorLine] [int] NOT NULL,
	[ErrorProcedure] [nvarchar](50) NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL,
	[ErrorDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DBError] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EstadoCuenta]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EstadoCuenta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTCM] [int] NOT NULL,
	[FechaCorte] [date] NOT NULL,
	[SaldoActual] [money] NOT NULL,
	[PagoContratado] [money] NOT NULL,
	[PagoMinimo] [money] NOT NULL,
	[FechaPago] [date] NOT NULL,
	[InteresesCorrientes] [money] NOT NULL,
	[InteresesMoratorios] [money] NOT NULL,
	[CantidadOperaciones] [int] NOT NULL,
	[CantidadOperacionesMes] [int] NOT NULL,
	[SumaPagosAntesFecha] [money] NOT NULL,
	[SumaPagosMes] [money] NOT NULL,
	[CantidadPagosMes] [int] NOT NULL,
	[CantidadCompras] [int] NOT NULL,
	[CantidadRetiros] [int] NOT NULL,
	[SumaCompras] [money] NOT NULL,
	[SumaRetiros] [money] NOT NULL,
	[CantidadCreditos] [int] NOT NULL,
	[SumaCreditos] [money] NOT NULL,
	[CantidadDebitos] [int] NOT NULL,
	[SumaDebitos] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MIT]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MIT](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Movimiento]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Movimiento](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[idTF] [int] NOT NULL,
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
/****** Object:  Table [dbo].[RN]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RN](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[idTTCM] [int] NOT NULL,
	[idTRN] [int] NOT NULL,
	[Valor] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubEstadoCuenta]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubEstadoCuenta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTCA] [int] NOT NULL,
	[CantidadOperaciones] [int] NOT NULL,
	[CantidadOperacionesATM] [int] NOT NULL,
	[SumaCompras] [money] NOT NULL,
	[SumaRetiros] [money] NOT NULL,
	[CantidadRetiros] [int] NOT NULL,
	[SumaCreditos] [money] NOT NULL,
	[SumaDebitos] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TCA]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TCA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTCM] [int] NOT NULL,
	[Codigo] [varchar](32) NOT NULL,
	[idTH] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TCM]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TCM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](32) NOT NULL,
	[idTTCM] [int] NOT NULL,
	[LimiteCredito] [money] NOT NULL,
	[idTH] [int] NOT NULL,
	[FechaCreacion] [date] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TF]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TF](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](64) NOT NULL,
	[CodigoTC] [varchar](64) NOT NULL,
	[FechaVencimiento] [date] NOT NULL,
	[CCV] [varchar](4) NOT NULL,
	[EsActiva] [bit] NOT NULL,
	[FechaCreacion] [date] NOT NULL,
	[idMotivoInvalidacion] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TH]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TH](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[DocumentoIdentidad] [varchar](32) NOT NULL,
	[FechaNacimiento] [date] NOT NULL,
	[NombreUsuario] [varchar](32) NOT NULL,
	[Password] [varchar](32) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TM]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[Accion] [varchar](64) NOT NULL,
	[AcumulaOperacionesATM] [bit] NOT NULL,
	[AcumulaOperacionesVentana] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TMIC]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMIC](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TMIM]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMIM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TRN]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TRN](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[Tipo] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TTCM]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TTCM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UA]    Script Date: 15/11/2024 20:03:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](64) NOT NULL,
	[Password] [varchar](64) NOT NULL,
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
ALTER TABLE [dbo].[RN]  WITH CHECK ADD FOREIGN KEY([idTRN])
REFERENCES [dbo].[TRN] ([id])
GO
ALTER TABLE [dbo].[RN]  WITH CHECK ADD FOREIGN KEY([idTTCM])
REFERENCES [dbo].[TTCM] ([id])
GO
ALTER TABLE [dbo].[SubEstadoCuenta]  WITH CHECK ADD FOREIGN KEY([idTCA])
REFERENCES [dbo].[TCA] ([id])
GO
ALTER TABLE [dbo].[TCA]  WITH CHECK ADD FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[TCA]  WITH CHECK ADD  CONSTRAINT [FK_TCA_TCM] FOREIGN KEY([idTCM])
REFERENCES [dbo].[TCM] ([id])
GO
ALTER TABLE [dbo].[TCA] CHECK CONSTRAINT [FK_TCA_TCM]
GO
ALTER TABLE [dbo].[TCM]  WITH CHECK ADD FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[TCM]  WITH CHECK ADD FOREIGN KEY([idTTCM])
REFERENCES [dbo].[TTCM] ([id])
GO
ALTER TABLE [dbo].[TF]  WITH CHECK ADD FOREIGN KEY([idMotivoInvalidacion])
REFERENCES [dbo].[MIT] ([id])
GO
USE [master]
GO
ALTER DATABASE [sistemaTarjetaCredito] SET  READ_WRITE 
GO
