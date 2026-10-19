/* Sesión 1 · Ejercicio 6 · Segmento de un usuario (IF ... ELSE IF y RETURN) */
USE SonoraDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_segmento_usuario
    @nombre_usuario  nvarchar(50),
    @desde           date,
    @hasta           date
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @minutos decimal(8,1), @segmento nvarchar(20);

    IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE nombre_usuario = @nombre_usuario)
    BEGIN
        PRINT N'Usuario no encontrado: ' + @nombre_usuario;
        RETURN 1;
    END;

    SELECT @minutos = CAST(COALESCE(SUM(r.segundos_escuchados), 0) / 60.0 AS decimal(8,1))
    FROM dbo.reproducciones AS r
    JOIN dbo.usuarios       AS u ON u.usuario_id = r.usuario_id
    WHERE u.nombre_usuario = @nombre_usuario
      AND r.tipo_contenido = N'Canción'
      AND r.segundos_escuchados >= 30
      AND r.fecha_hora >= @desde
      AND r.fecha_hora <  @hasta;

    IF @minutos >= 10
        SET @segmento = N'Intensivo';
    ELSE IF @minutos >= 6
        SET @segmento = N'Habitual';
    ELSE IF @minutos > 0
        SET @segmento = N'Ocasional';
    ELSE
        SET @segmento = N'Sin actividad';

    SELECT @nombre_usuario AS nombre_usuario, @minutos AS minutos, @segmento AS segmento;

    RETURN 0;
END;
GO

-- Ejecutar el bloque completo de una vez
DECLARE @estado int;

EXEC @estado = dbo.usp_segmento_usuario N'lucia.m',    '2026-09-16', '2026-09-23';
SELECT N'lucia.m' AS usuario, @estado AS estado;

EXEC @estado = dbo.usp_segmento_usuario N'marta_rock', '2026-09-16', '2026-09-23';
SELECT N'marta_rock' AS usuario, @estado AS estado;

EXEC @estado = dbo.usp_segmento_usuario N'sofi.trap',  '2026-09-16', '2026-09-23';
SELECT N'sofi.trap' AS usuario, @estado AS estado;

EXEC @estado = dbo.usp_segmento_usuario N'vale_indie', '2026-09-16', '2026-09-23';
SELECT N'vale_indie' AS usuario, @estado AS estado;

EXEC @estado = dbo.usp_segmento_usuario N'fantasma',   '2026-09-16', '2026-09-23';
SELECT N'fantasma' AS usuario, @estado AS estado;
