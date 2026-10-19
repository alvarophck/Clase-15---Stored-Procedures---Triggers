/* Sesión 2 · Ejercicio 1 · Registrar altas de artistas */
USE SonoraDB;
GO

DROP TABLE IF EXISTS dbo.altas_artistas;

CREATE TABLE dbo.altas_artistas (
    artista_id  int            NOT NULL,
    nombre      nvarchar(100)  NOT NULL,
    fecha_alta  datetime2(0)   NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE OR ALTER TRIGGER dbo.trg_artistas_alta
ON dbo.artistas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.altas_artistas (artista_id, nombre)
    SELECT i.artista_id, i.nombre
    FROM inserted AS i;
END;
GO

-- Dos altas en una sola instrucción
INSERT INTO dbo.artistas (artista_id, nombre, pais, genero_id) VALUES
(10, N'Aurora Boreal',  'ES', 11),
(11, N'Trío Magnético', 'MX', 9);

SELECT artista_id, nombre, fecha_alta
FROM dbo.altas_artistas
ORDER BY artista_id;
GO

-- Borrar los dos artistas y volver a mirar
DELETE FROM dbo.artistas WHERE artista_id IN (10, 11);

SELECT artista_id, nombre, fecha_alta
FROM dbo.altas_artistas
ORDER BY artista_id;
GO

/* Respuesta:
   altas_artistas no cambia: sigue con las dos filas. El trigger solo atiende a
   INSERT, así que el DELETE no lo dispara, y nada borra el registro de las altas.
   Es lo esperable en un registro histórico: anota que el alta ocurrió. */

DROP TRIGGER IF EXISTS dbo.trg_artistas_alta;
