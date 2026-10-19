/* Sesión 1 · Ejercicio 5 · Actividad de un usuario con parámetros OUTPUT */
USE SonoraDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_actividad_usuario
    @nombre_usuario  nvarchar(50),
    @reproducciones  int           OUTPUT,
    @minutos         decimal(8,1)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @reproducciones = COUNT(*),
           @minutos        = CAST(COALESCE(SUM(r.segundos_escuchados), 0) / 60.0 AS decimal(8,1))
    FROM dbo.reproducciones AS r
    JOIN dbo.usuarios       AS u ON u.usuario_id = r.usuario_id
    WHERE u.nombre_usuario = @nombre_usuario
      AND r.tipo_contenido = N'Canción'
      AND r.segundos_escuchados >= 30;
END;
GO

-- Ejecutar el bloque completo de una vez
DECLARE @n int, @min decimal(8,1);

EXEC dbo.usp_actividad_usuario @nombre_usuario = N'alexbeats',
     @reproducciones = @n OUTPUT, @minutos = @min OUTPUT;
SELECT N'alexbeats' AS usuario, @n AS reproducciones, @min AS minutos;

EXEC dbo.usp_actividad_usuario @nombre_usuario = N'vale_indie',
     @reproducciones = @n OUTPUT, @minutos = @min OUTPUT;
SELECT N'vale_indie' AS usuario, @n AS reproducciones, @min AS minutos;

EXEC dbo.usp_actividad_usuario @nombre_usuario = N'fantasma',
     @reproducciones = @n OUTPUT, @minutos = @min OUTPUT;
SELECT N'fantasma' AS usuario, @n AS reproducciones, @min AS minutos;
GO

/* Respuesta:
   vale_indie (existe, sin reproducciones válidas) y fantasma (no existe) devuelven
   lo mismo: 0 y 0.0. Con estos dos parámetros no se pueden distinguir. Se resolvería
   validando la existencia del usuario (THROW o código de retorno) o añadiendo un
   tercer parámetro de salida, por ejemplo @existe bit. */
