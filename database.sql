USE [master]
GO
/****** Object:  Database [sistemaTarjetaCredito]    Script Date: 12/11/2024 21:55:52 ******/
CREATE DATABASE [sistemaTarjetaCredito]
GO
USE [sistemaTarjetaCredito]
GO
/****** Object:  Table [dbo].[DBError]    Script Date: 12/11/2024 21:55:52 ******/
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
/****** Object:  Table [dbo].[MIT]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MIT](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
 CONSTRAINT [PK_MIT] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Movimiento]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Movimiento](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
	[idTF] [int] NOT NULL,
	[FechaMovimiento] [date] NOT NULL,
	[Monto] [money] NOT NULL,
	[Descripcion] [varchar](64) NOT NULL,
	[Referencia] [varchar](32) NOT NULL,
 CONSTRAINT [PK_Movimiento] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MovimientoPorInteresCorriente]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MovimientoPorInteresCorriente](
	[idMovimiento] [int] NOT NULL,
 CONSTRAINT [PK_MovimientoPorInteresCorriente] PRIMARY KEY CLUSTERED 
(
	[idMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MovimientoPorInteresMoratorio]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MovimientoPorInteresMoratorio](
	[idMovimiento] [int] NOT NULL,
 CONSTRAINT [PK_MovimientoPorInteresMoratorio] PRIMARY KEY CLUSTERED 
(
	[idMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MovimientoSospechoso]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MovimientoSospechoso](
	[idMovimiento] [int] NOT NULL,
 CONSTRAINT [PK_MovimientoSospechoso] PRIMARY KEY CLUSTERED 
(
	[idMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RN]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RN](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](128) NOT NULL,
	[idTTCM] [int] NOT NULL,
	[idTRN] [int] NOT NULL,
	[Valor] [varchar](32) NOT NULL,
 CONSTRAINT [PK_RN] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RP]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RP](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTF] [int] NOT NULL,
	[Razon] [varchar](20) NOT NULL,
 CONSTRAINT [PK_RP] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TCA]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TCA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](32) NOT NULL,
	[idTCM] [int] NOT NULL,
	[idTH] [int] NOT NULL,
 CONSTRAINT [PK_TCA] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TCM]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TCM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](32) NOT NULL,
	[idTTCM] [int] NOT NULL,
	[LimiteCredito] [money] NOT NULL,
	[Saldo] [money] NOT NULL,
	[idTH] [int] NOT NULL,
 CONSTRAINT [PK_TCM] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TF]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TF](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](32) NOT NULL,
	[idTCM] [int] NOT NULL,
	[idTH] [int] NOT NULL,
	[Numero] [varchar](32) NOT NULL,
	[FechaVencimiento] [date] NOT NULL,
	[CCV] [varchar](32) NOT NULL,
	[EsActiva] [bit] NOT NULL,
	[FechaCreacion] [date] NOT NULL,
 CONSTRAINT [PK_TF] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TH]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TH](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[ValorDocIdentidad] [varchar](64) NOT NULL,
	[FechaNacimiento] [date] NOT NULL,
	[NombreUsuario] [varchar](32) NOT NULL,
	[Password] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TH] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TM]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[Accion] [varchar](32) NOT NULL,
	[Acumula_Operacion_ATM] [varchar](32) NOT NULL,
	[Acumula_Operacion_Ventana] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TM] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TMIC]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMIC](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
 CONSTRAINT [PK_TMIC] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TMIM]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMIM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
 CONSTRAINT [PK_TMIM] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TRN]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TRN](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[Tipo] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TRN] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TTCM]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TTCM](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
 CONSTRAINT [PK_TTCM] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UA]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[Password] [varchar](64) NOT NULL,
 CONSTRAINT [PK_UA] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Movimiento]  WITH CHECK ADD  CONSTRAINT [FK_Movimiento_TF] FOREIGN KEY([idTF])
REFERENCES [dbo].[TF] ([id])
GO
ALTER TABLE [dbo].[Movimiento] CHECK CONSTRAINT [FK_Movimiento_TF]
GO
ALTER TABLE [dbo].[MovimientoPorInteresCorriente]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoPorInteresCorriente_Movimiento] FOREIGN KEY([idMovimiento])
REFERENCES [dbo].[Movimiento] ([id])
GO
ALTER TABLE [dbo].[MovimientoPorInteresCorriente] CHECK CONSTRAINT [FK_MovimientoPorInteresCorriente_Movimiento]
GO
ALTER TABLE [dbo].[MovimientoPorInteresMoratorio]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoPorInteresMoratorio_Movimiento] FOREIGN KEY([idMovimiento])
REFERENCES [dbo].[Movimiento] ([id])
GO
ALTER TABLE [dbo].[MovimientoPorInteresMoratorio] CHECK CONSTRAINT [FK_MovimientoPorInteresMoratorio_Movimiento]
GO
ALTER TABLE [dbo].[MovimientoSospechoso]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoSospechoso_Movimiento] FOREIGN KEY([idMovimiento])
REFERENCES [dbo].[Movimiento] ([id])
GO
ALTER TABLE [dbo].[MovimientoSospechoso] CHECK CONSTRAINT [FK_MovimientoSospechoso_Movimiento]
GO
ALTER TABLE [dbo].[RN]  WITH CHECK ADD  CONSTRAINT [FK_RN_TRN] FOREIGN KEY([idTRN])
REFERENCES [dbo].[TRN] ([id])
GO
ALTER TABLE [dbo].[RN] CHECK CONSTRAINT [FK_RN_TRN]
GO
ALTER TABLE [dbo].[RN]  WITH CHECK ADD  CONSTRAINT [FK_RN_TTCM] FOREIGN KEY([idTTCM])
REFERENCES [dbo].[TTCM] ([id])
GO
ALTER TABLE [dbo].[RN] CHECK CONSTRAINT [FK_RN_TTCM]
GO
ALTER TABLE [dbo].[RP]  WITH CHECK ADD  CONSTRAINT [FK_RP_TF] FOREIGN KEY([idTF])
REFERENCES [dbo].[TF] ([id])
GO
ALTER TABLE [dbo].[RP] CHECK CONSTRAINT [FK_RP_TF]
GO
ALTER TABLE [dbo].[TCA]  WITH CHECK ADD  CONSTRAINT [FK_TCA_TCM] FOREIGN KEY([idTCM])
REFERENCES [dbo].[TCM] ([id])
GO
ALTER TABLE [dbo].[TCA] CHECK CONSTRAINT [FK_TCA_TCM]
GO
ALTER TABLE [dbo].[TCA]  WITH CHECK ADD  CONSTRAINT [FK_TCA_TH] FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[TCA] CHECK CONSTRAINT [FK_TCA_TH]
GO
ALTER TABLE [dbo].[TCM]  WITH CHECK ADD  CONSTRAINT [FK_TCM_TH] FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[TCM] CHECK CONSTRAINT [FK_TCM_TH]
GO
ALTER TABLE [dbo].[TCM]  WITH CHECK ADD  CONSTRAINT [FK_TCM_TTCM] FOREIGN KEY([idTTCM])
REFERENCES [dbo].[TTCM] ([id])
GO
ALTER TABLE [dbo].[TCM] CHECK CONSTRAINT [FK_TCM_TTCM]
GO
ALTER TABLE [dbo].[TF]  WITH CHECK ADD  CONSTRAINT [FK_TF_TCM] FOREIGN KEY([idTCM])
REFERENCES [dbo].[TCM] ([id])
GO
ALTER TABLE [dbo].[TF] CHECK CONSTRAINT [FK_TF_TCM]
GO
ALTER TABLE [dbo].[TF]  WITH CHECK ADD  CONSTRAINT [FK_TF_TH] FOREIGN KEY([idTH])
REFERENCES [dbo].[TH] ([id])
GO
ALTER TABLE [dbo].[TF] CHECK CONSTRAINT [FK_TF_TH]
GO
/****** Object:  StoredProcedure [dbo].[verificarUsuario]    Script Date: 12/11/2024 21:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[verificarUsuario] (
    @nombre VARCHAR(50),
    @password VARCHAR(50),
    @OutTipoUsuario INT OUTPUT,
    @OutResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicializar el código de resultado y el tipo de usuario
        SET @OutResultCode = 0;

        -- Verificar en la tabla de usuarios administrativos (UA)
        IF EXISTS (
            SELECT 1 
            FROM UA 
            WHERE Nombre = @nombre 
            AND Password = @password
        )
        BEGIN
            -- Autenticación exitosa como usuario adiministrativo (UA)
            SET @OutTipoUsuario = 0;
        END
        ELSE IF EXISTS (
            -- Verificar en la tabla de tarjetahabientes (TH)
            SELECT 1 
            FROM TH 
            WHERE NombreUsuario = @nombre 
            AND Password = @password
        )
        BEGIN
            -- Autenticación exitosa como tarjetahabiente (TH)
            SET @OutTipoUsuario = 1;
        END
        ELSE
        BEGIN
            -- Autenticación fallida
            SET @OutResultCode = 50001
        END
    END TRY
    BEGIN CATCH
    -- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
        ROLLBACK TRANSACTION;
        END;
        -- Asignar el código de error de la base de datos al resultado de salida
        SET @OutResultCode = 50008;

        -- Registrar el error en la tabla DBError
        INSERT INTO [sistemaTarjetaCredito].[dbo].[DBError]
        (
        ErrorUsername,
        ErrorNumber,
        ErrorState,
        ErrorSeverity,
        ErrorLine,
        ErrorProcedure,
        ErrorMessage,
        ErrorDateTime)
		VALUES
        (SUSER_NAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());
    END CATCH

    SET NOCOUNT OFF;
END;
GO
USE [master]
GO
ALTER DATABASE [sistemaTarjetaCredito] SET  READ_WRITE 
GO
