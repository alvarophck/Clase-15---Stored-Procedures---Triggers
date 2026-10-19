/* =====================================================================
   Sesión 1 · Stored Procedures
   00 · Prerrequisitos: objetos de la teoría que usan los ejercicios
   ---------------------------------------------------------------------
   Ejecutar DESPUÉS del script del punto de partida de la Sesión 1.
   Es seguro ejecutarlo aunque ya se hiciera la teoría: los procedimientos
   se sustituyen y las tablas solo se crean si no existen.
   ===================================================================== */
USE SonoraDB;
GO

-- usp_top_canciones (versión del Ejemplo 4) -> Ejercicio 3
CREATE OR ALTER PROCEDURE dbo.usp_top_canciones
    @desde  date,
    @hasta  date,
    @top    int           = 3,
    @plan   nvarchar(20)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top) c.titulo, a.nombre AS artista, COUNT(*) AS reproducciones
    FROM dbo.reproducciones AS r
    JOIN dbo.canciones AS c ON c.cancion_id = r.cancion_id
    JOIN dbo.artistas  AS a ON a.artista_id = c.artista_id
    JOIN dbo.usuarios  AS u ON u.usuario_id = r.usuario_id
    WHERE r.tipo_contenido = N'Canción'
      AND r.segundos_escuchados >= 30
      AND r.fecha_hora >= @desde
      AND r.fecha_hora <  @hasta
      AND (@plan IS NULL OR u.plan_suscripcion = @plan)
    GROUP BY c.titulo, a.nombre
    ORDER BY reproducciones DESC, c.titulo;
END;
GO

-- usp_cifras_periodo (Ejemplo 5) -> Ejercicio 7
CREATE OR ALTER PROCEDURE dbo.usp_cifras_periodo
    @desde           date,
    @hasta           date,
    @reproducciones  int           OUTPUT,
    @minutos         decimal(8,1)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @reproducciones = COUNT(*),
           @minutos        = CAST(COALESCE(SUM(segundos_escuchados), 0) / 60.0 AS decimal(8,1))
    FROM dbo.reproducciones
    WHERE tipo_contenido = N'Canción'
      AND segundos_escuchados >= 30
      AND fecha_hora >= @desde
      AND fecha_hora <  @hasta;
END;
GO

-- Tabla resumen (Ejemplo 6) -> Ejercicios 11 y 12
IF OBJECT_ID(N'dbo.resumen_diario', N'U') IS NULL
    CREATE TABLE dbo.resumen_diario (
        dia             date          NOT NULL PRIMARY KEY,
        reproducciones  int           NOT NULL,
        oyentes         int           NOT NULL,
        minutos         decimal(8,1)  NOT NULL
    );
GO

-- Tabla de log (Ejemplo 13) -> Ejercicios 11, 12 y 13
IF OBJECT_ID(N'dbo.log_cargas', N'U') IS NULL
    CREATE TABLE dbo.log_cargas (
        log_id            int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        proceso           nvarchar(100)   NOT NULL,
        inicio            datetime2(0)    NOT NULL,
        fin               datetime2(0)    NULL,
        filas_leidas      int             NULL,
        filas_insertadas  int             NULL,
        filas_rechazadas  int             NULL,
        estado            nvarchar(10)    NOT NULL,
        mensaje_error     nvarchar(4000)  NULL
    );
GO

-- Comprobación
SELECT ROUTINE_NAME
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = N'PROCEDURE'
ORDER BY ROUTINE_NAME;
