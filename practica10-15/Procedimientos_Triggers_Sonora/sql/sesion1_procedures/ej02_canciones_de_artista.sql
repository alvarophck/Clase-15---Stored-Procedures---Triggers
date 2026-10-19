/* Sesión 1 · Ejercicio 2 · Catálogo de un artista */
USE SonoraDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_canciones_de_artista
    @artista  nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT c.titulo, c.duracion_seg, c.fecha_lanzamiento
    FROM dbo.canciones AS c
    JOIN dbo.artistas  AS a ON a.artista_id = c.artista_id
    WHERE a.nombre = @artista
    ORDER BY c.fecha_lanzamiento;
END;
GO

EXEC dbo.usp_canciones_de_artista @artista = N'MC Brisa';

EXEC dbo.usp_canciones_de_artista @artista = N'Los Planetas';

/* Respuesta:
   Para 'Los Planetas' devuelve un resultado vacío (cabeceras sin filas) y ningún
   error. Desde fuera no se distingue "el artista no existe" de "existe y no tiene
   canciones": las dos situaciones producen exactamente la misma salida. Haría falta
   comprobar antes si el artista existe (IF NOT EXISTS ... THROW) o devolver un
   código de retorno distinto. */
