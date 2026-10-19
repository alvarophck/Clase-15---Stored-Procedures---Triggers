/* Sesión 2 · Ejercicio 3 · Cuántas filas hay en inserted y deleted
   Predicción:  a) 4/4   b) 0/0   c) 2/0   d) 1/1   e) 10/10  (inserted/deleted) */
USE SonoraDB;
GO

DROP TABLE IF EXISTS dbo.conteo_trigger;

CREATE TABLE dbo.conteo_trigger (
    filas_inserted  int NOT NULL,
    filas_deleted   int NOT NULL
);
GO

CREATE OR ALTER TRIGGER dbo.trg_usuarios_conteo
ON dbo.usuarios
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.conteo_trigger (filas_inserted, filas_deleted)
    SELECT (SELECT COUNT(*) FROM inserted),
           (SELECT COUNT(*) FROM deleted);
END;
GO

-- a)
BEGIN TRAN;
    UPDATE dbo.usuarios SET pais = 'ES' WHERE pais = 'ES';
    SELECT 'a' AS instruccion, filas_inserted, filas_deleted FROM dbo.conteo_trigger;
ROLLBACK;
GO

-- b)
BEGIN TRAN;
    DELETE FROM dbo.usuarios WHERE usuario_id > 10;
    SELECT 'b' AS instruccion, filas_inserted, filas_deleted FROM dbo.conteo_trigger;
ROLLBACK;
GO

-- c)
BEGIN TRAN;
    INSERT INTO dbo.usuarios (usuario_id, nombre_usuario, email, pais, plan_suscripcion, fecha_alta) VALUES
    (11, N'teo.bass',  N'teo.bass@mail.com',  'ES', N'Free',    '2026-09-24'),
    (12, N'ines_wave', N'ines.wave@mail.com', 'CO', N'Premium', '2026-09-24');
    SELECT 'c' AS instruccion, filas_inserted, filas_deleted FROM dbo.conteo_trigger;
ROLLBACK;
GO

-- d)
BEGIN TRAN;
    UPDATE dbo.usuarios SET plan_suscripcion = N'Premium' WHERE plan_suscripcion = N'Free' AND pais = 'MX';
    SELECT 'd' AS instruccion, filas_inserted, filas_deleted FROM dbo.conteo_trigger;
ROLLBACK;
GO

-- e)
BEGIN TRAN;
    UPDATE dbo.usuarios SET email = email;
    SELECT 'e' AS instruccion, filas_inserted, filas_deleted FROM dbo.conteo_trigger;
ROLLBACK;
GO

DROP TRIGGER IF EXISTS dbo.trg_usuarios_conteo;
DROP TABLE IF EXISTS dbo.conteo_trigger;
