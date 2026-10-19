/* Sesión 2 · Ejercicio 6 · Un único trigger de auditoría para artistas */
USE SonoraDB;
GO

DROP TABLE IF EXISTS dbo.aud_artistas;

CREATE TABLE dbo.aud_artistas (
    auditoria_id  int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    operacion     char(1)        NOT NULL CHECK (operacion IN ('I', 'U', 'D')),
    artista_id    int            NOT NULL,
    nombre        nvarchar(100)  NOT NULL,
    fecha         datetime2(0)   NOT NULL DEFAULT SYSDATETIME(),
    usuario_bd    nvarchar(128)  NOT NULL DEFAULT USER_NAME()
);
GO

CREATE OR ALTER TRIGGER dbo.trg_artistas_auditoria
ON dbo.artistas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.aud_artistas (operacion, artista_id, nombre)
        SELECT 'U', i.artista_id, i.nombre
        FROM inserted AS i;
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        INSERT INTO dbo.aud_artistas (operacion, artista_id, nombre)
        SELECT 'I', i.artista_id, i.nombre
        FROM inserted AS i;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.aud_artistas (operacion, artista_id, nombre)
        SELECT 'D', d.artista_id, d.nombre
        FROM deleted AS d;
    -- Si las dos están vacías, la instrucción no tocó ninguna fila: no se anota nada
END;
GO

INSERT INTO dbo.artistas (artista_id, nombre, pais, genero_id) VALUES
(10, N'Aurora Boreal',  'ES', 11),
(11, N'Trío Magnético', 'MX', 9);

UPDATE dbo.artistas SET nombre = N'Aurora Boreal & Cía' WHERE artista_id = 10;

UPDATE dbo.artistas SET pais = 'PT' WHERE artista_id = 999;

DELETE FROM dbo.artistas WHERE artista_id IN (10, 11);
GO

SELECT operacion, artista_id, nombre, fecha, usuario_bd
FROM dbo.aud_artistas
ORDER BY operacion, artista_id;
GO

DROP TRIGGER IF EXISTS dbo.trg_artistas_auditoria;
