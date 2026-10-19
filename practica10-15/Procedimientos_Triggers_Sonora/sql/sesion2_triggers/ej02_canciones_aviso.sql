/* Sesión 2 · Ejercicio 2 · ¿Cuándo se dispara?
   Ejecutar cada instrucción POR SEPARADO y mirar la pestaña Messages. */
USE SonoraDB;
GO

CREATE OR ALTER TRIGGER dbo.trg_canciones_aviso
ON dbo.canciones
AFTER UPDATE, DELETE
AS
BEGIN
    PRINT N'>> trg_canciones_aviso';
END;
GO

-- a) SÍ. UPDATE de 3 filas: un único aviso
UPDATE dbo.canciones SET duracion_seg = duracion_seg WHERE artista_id = 2;

-- b) SÍ. UPDATE que no encuentra filas: se dispara igual (0 rows affected)
UPDATE dbo.canciones SET titulo = N'Sin título' WHERE cancion_id = 500;

-- c) NO. El trigger no vigila INSERT
INSERT INTO dbo.canciones (cancion_id, titulo, artista_id, genero_id, duracion_seg, fecha_lanzamiento)
VALUES (116, N'Prueba', 1, 2, 100, '2026-09-25');

-- d) NO. Falla por la FOREIGN KEY de reproducciones (Msg 547): un trigger AFTER
--    no se dispara tras una instrucción que no supera las restricciones
DELETE FROM dbo.canciones WHERE cancion_id = 103;

-- e) SÍ. Borra la canción de prueba
DELETE FROM dbo.canciones WHERE cancion_id = 116;

-- f) NO. Es otra tabla
UPDATE dbo.artistas SET pais = pais WHERE artista_id = 2;
GO

DROP TRIGGER IF EXISTS dbo.trg_canciones_aviso;
