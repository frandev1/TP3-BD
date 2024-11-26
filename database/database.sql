USE [master]
GO
/****** Object:  Database [sistemaTarjetaCredito]    Script Date: 20/11/2024 01:23:28 ******/
CREATE DATABASE [sistemaTarjetaCredito]
GO
USE [sistemaTarjetaCredito]
GO
/****** Object:  Table [dbo].[DBError]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[EstadoCuenta]    Script Date: 20/11/2024 01:23:28 ******/
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
	[CantidadOperacionesATM] [int] NOT NULL,
	[CantidadOperacionesVentanilla] [int] NOT NULL,
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
 CONSTRAINT [PK__EstadoCu__3213E83FAB365001] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MIT]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[Movimiento]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Movimiento](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[idTF] [int] NULL,
	[FechaMovimiento] [date] NOT NULL,
	[Monto] [money] NOT NULL,
	[Descripcion] [varchar](64) NOT NULL,
	[Referencia] [varchar](64) NOT NULL,
	[EsSospechoso] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RN]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RN](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[idTTCM] [int] NOT NULL,
	[idTRN] [int] NOT NULL,
	[Valor] [float] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubEstadoCuenta]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubEstadoCuenta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTCA] [int] NOT NULL,
	[FechaCorte] [date] NOT NULL,
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
/****** Object:  Table [dbo].[TCA]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[TCM]    Script Date: 20/11/2024 01:23:28 ******/
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
	[FechaCreacion] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TF]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[TH]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[TM]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[TMIC]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[TMIM]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[TRN]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[TTCM]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  Table [dbo].[UA]    Script Date: 20/11/2024 01:23:28 ******/
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
/****** Object:  StoredProcedure [dbo].[ObtenerEstadoCuenta]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerEstadoCuenta]
    @idTCM INT
AS
BEGIN
    SELECT
        EC.FechaCorte,
        EC.PagoMinimo,
        EC.PagoContratado,
        EC.InteresesCorrientes,
        EC.InteresesMoratorios,
        EC.CantidadOperacionesATM,
        EC.CantidadOperacionesVentanilla
    FROM EstadoCuenta EC
    WHERE idTCM = @idTCM
    ORDER BY EC.FechaCorte DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[ObtenerEstadosCuenta]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ObtenerEstadosCuenta]
    @inCodigoTC VARCHAR(64),
    @OutResultCode INT
AS
BEGIN
    SET NOCOUNT ON;
END
GO
/****** Object:  StoredProcedure [dbo].[ObtenerMovimientosPorTarjetaFisica]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ObtenerMovimientosPorTarjetaFisica]
    @inCodigoTarjetaFisica VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    -- Consulta para obtener los movimientos de la tarjeta física
    SELECT 
        M.FechaMovimiento AS [Fecha de Operación],
        M.Nombre AS [Nombre de Tipo de Movimiento], -- Mantenemos el nombre directamente desde Movimiento
        M.Descripcion AS [Descripción],
        M.Referencia,
        M.Monto,
        -- Cálculo del nuevo saldo acumulado
        SUM(M.Monto) OVER (PARTITION BY M.idTF ORDER BY M.FechaMovimiento ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Nuevo Saldo]
    FROM Movimiento M
    INNER JOIN TF ON M.idTF = TF.id
    WHERE TF.CodigoTC = @inCodigoTarjetaFisica -- Filtro por el código de la tarjeta física
    ORDER BY M.FechaMovimiento ASC; -- Orden por fecha
END;
GO
/****** Object:  StoredProcedure [dbo].[ObtenerTarjetasAsociadasTH]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerTarjetasAsociadasTH]
    @inUsuarioTH VARCHAR(32),  -- Nombre de usuario de la TH
    @OutResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Se inicializa la variable de salida
        SET @OutResultCode = 0;

        DECLARE @idTH INT;

        -- Obtener el id del tarjetahabiente
        SELECT @idTH = TH.id
        FROM [sistemaTarjetaCredito].[dbo].[TH] TH
        WHERE NombreUsuario = @inUsuarioTH;

        -- Verificar que el id se obtuvo correctamente
        IF @idTH IS NULL
        BEGIN
            SET @OutResultCode = 50002;  -- Código de error para usuario no encontrado
            RAISERROR('Usuario no encontrado.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION

        -- Seleccionar solo las tarjetas asociadas al tarjetahabiente específico (TH)
        SELECT DISTINCT
            TF.Codigo AS NumeroTarjeta,  -- Código de la tarjeta
            CASE
                WHEN TF.EsActiva = 1 THEN 'Activa'
                WHEN TF.EsActiva = 0 THEN 'Inactiva'
            END AS EstadoCuenta,
            TF.FechaVencimiento,
            CASE 
                WHEN TCA.id IS NOT NULL THEN 'TCA'
                WHEN TCM.id IS NOT NULL THEN 'TCM'
                ELSE NULL
            END AS TipoCuenta,
            TF.FechaCreacion
        FROM 
            [sistemaTarjetaCredito].[dbo].[TF] TF
        LEFT JOIN TCA TCA ON TF.CodigoTC = TCA.Codigo AND TCA.idTH = @idTH -- Unir con TCA asegurando el idTH
        LEFT JOIN TCM TCM ON TF.CodigoTC = TCM.Codigo AND TCM.idTH = @idTH -- Unir con TCM asegurando el idTH
        WHERE 
            TCA.idTH = @idTH OR TCM.idTH = @idTH 
        ORDER BY 
            TF.FechaCreacion DESC;

        COMMIT TRANSACTION
        
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
            ErrorDateTime
        )
        VALUES
        (
            SUSER_NAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

    SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ObtenerTodasLasTarjetas]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ObtenerTodasLasTarjetas]
    @inNombreUsuario VARCHAR(50),
    @OutResultCode INT OUTPUT  
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar si el usuario es administrador (cambiado para reflejar la nueva estructura de `UA` si aplica)
        IF EXISTS (
            SELECT 1
            FROM UA  -- Asegúrate de que `UA` existe y contiene los nombres de usuario
            WHERE Username = @inNombreUsuario
        )
        BEGIN
            -- Selección de tarjetas TCM y TCA unidas con TF y TH según la nueva estructura
            SELECT DISTINCT
                'TCM' AS TipoTarjeta,
                TCM.Codigo AS CodigoTarjeta,
                TF.Codigo AS CodigoTarjetaFisica,
                TH.Nombre AS NombreTarjetahabiente
            FROM TCM
            INNER JOIN TF ON TCM.id = TF.id  -- Asegúrate de que `TF.id` está correctamente relacionado con `TCM.id`
            INNER JOIN TH ON TCM.idTH = TH.id

            UNION ALL

            SELECT DISTINCT
                'TCA' AS TipoTarjeta,
                TCA.Codigo AS CodigoTarjeta,
                TF.Codigo AS CodigoTarjetaFisica,
                TH.Nombre AS NombreTarjetahabiente
            FROM TCA
            INNER JOIN TF ON TCA.id = TF.id  -- Asegúrate de que `TF.id` está correctamente relacionado con `TCA.id`
            INNER JOIN TH ON TCA.idTH = TH.id;

            -- Establecer el código de salida exitoso
            SET @OutResultCode = 0;
        END
        ELSE
        BEGIN
            -- Si no es administrador, establecer código de error
            SET @OutResultCode = 50001;  
            RAISERROR('Usuario no autorizado.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @OutResultCode = 50008;

        -- Insertar el error en la tabla DBError
        INSERT INTO [dbo].[DBError] (
            ErrorUserName,
            ErrorNumber,
            ErrorState,
            ErrorSeverity,
            ErrorLine,
            ErrorProcedure,
            ErrorMessage,
            ErrorDateTime
        )
        VALUES (
            SUSER_NAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );

        -- Lanzar mensaje de error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[verificarUsuario]    Script Date: 20/11/2024 01:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[verificarUsuario] (
    @inNombre VARCHAR(50),
    @inPassword VARCHAR(50),
    @OutTipoUsuario INT OUTPUT,
    @OutNombre VARCHAR(64) OUTPUT,
    @OutResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicializar los valores de salida
        SET @OutResultCode = 0;
        SET @OutTipoUsuario = NULL;
        SET @OutNombre = NULL;

        -- Verificar si el nombre de usuario existe en la tabla UA
        IF EXISTS (
            SELECT 1 
            FROM [sistemaTarjetaCredito].[dbo].[UA] UA 
            WHERE UA.Username = @inNombre
        )
        BEGIN
            -- Si el nombre existe, verificar la contraseña
            IF EXISTS (
                SELECT 1 
                FROM [sistemaTarjetaCredito].[dbo].[UA] UA 
                WHERE UA.Username = @inNombre 
                AND UA.Password = @inPassword
            )
            BEGIN
                -- Credenciales correctas para un usuario administrativo
                SET @OutTipoUsuario = 0;
            END
            ELSE
            BEGIN
                -- Contraseña incorrecta para un usuario administrativo
                SET @OutResultCode = 50002; -- Código para contraseña incorrecta
            END
        END
        ELSE IF EXISTS (
            -- Verificar si el nombre de usuario existe en la tabla TH
            SELECT 1 
            FROM [sistemaTarjetaCredito].[dbo].[TH] TH 
            WHERE TH.NombreUsuario = @inNombre
        )
        BEGIN
            -- Si el nombre existe, verificar la contraseña
            IF EXISTS (
                SELECT 1 
                FROM [sistemaTarjetaCredito].[dbo].[TH] TH 
                WHERE TH.NombreUsuario = @inNombre 
                AND TH.Password = @inPassword
            )
            BEGIN
                -- Credenciales correctas para un tarjetahabiente
                SET @OutTipoUsuario = 1;

                -- Devuelve opcionalmente el nombre del usuario
                SELECT @OutNombre = TH.Nombre
                FROM [sistemaTarjetaCredito].[dbo].[TH]
                WHERE TH.NombreUsuario = @inNombre;
            END
            ELSE
            BEGIN
                -- Contraseña incorrecta para un tarjetahabiente
                SET @OutResultCode = 50002; -- Código para contraseña incorrecta
            END
        END
        ELSE
        BEGIN
            -- Usuario no encontrado
            SET @OutResultCode = 50003; -- Código para usuario no encontrado
        END
    END TRY
    BEGIN CATCH
        -- Rollback en caso de error
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Asignar el código de error genérico
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
            ErrorDateTime
        )
        VALUES
        (
            SUSER_NAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );
    END CATCH;

    SET NOCOUNT OFF;
END;
GO
USE [master]
GO
ALTER DATABASE [sistemaTarjetaCredito] SET  READ_WRITE 
GO
