/* Sesión 1 · Ejercicio 13 · Carga completa de altas de usuarios */
USE SonoraDB;
GO

DROP TABLE IF EXISTS dbo.rechazos_altas;

CREATE TABLE dbo.rechazos_altas (
    log_id          int           NOT NULL,
    usuario_id      int           NULL,
    nombre_usuario  nvarchar(50)  NULL,
    motivo          nvarchar(60)  NOT NULL
);
GO

CREATE OR ALTER PROCEDURE dbo.usp_cargar_usuarios
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @log_id int, @leidas int, @insertadas int, @rechazadas int;

    -- 1. Anotar el inicio
    INSERT INTO dbo.log_cargas (proceso, inicio, estado)
    VALUES (N'usp_cargar_usuarios', SYSDATETIME(), N'En curso');

    SET @log_id = SCOPE_IDENTITY();

    BEGIN TRY
        SET @leidas = (SELECT COUNT(*) FROM dbo.stg_usuarios_2309);

        -- 2. Staging: sin duplicados, sin usuarios ya existentes, plan corregido y validado
        SELECT x.usuario_id, x.nombre_usuario, x.email, x.pais, x.plan_suscripcion, x.fecha_alta,
               CASE
                   WHEN x.email IS NULL
                       THEN N'Email vacío'
                   WHEN x.plan_suscripcion NOT IN (N'Free', N'Premium', N'Familiar')
                       THEN N'Plan no reconocido'
               END AS motivo
        INTO #lote_usuarios
        FROM (
            SELECT DISTINCT
                   s.usuario_id, s.nombre_usuario, s.email, s.pais,
                   CASE WHEN s.plan_suscripcion = N'Family' THEN N'Familiar'
                        ELSE s.plan_suscripcion
                   END AS plan_suscripcion,
                   s.fecha_alta
            FROM dbo.stg_usuarios_2309 AS s
            WHERE NOT EXISTS (SELECT 1 FROM dbo.usuarios AS u
                              WHERE u.usuario_id = s.usuario_id)
        ) AS x;

        -- 3. Carga: rechazos y altas correctas, todo o nada
        BEGIN TRAN;

            INSERT INTO dbo.rechazos_altas (log_id, usuario_id, nombre_usuario, motivo)
            SELECT @log_id, l.usuario_id, l.nombre_usuario, l.motivo
            FROM #lote_usuarios AS l
            WHERE l.motivo IS NOT NULL;

            SET @rechazadas = @@ROWCOUNT;

            INSERT INTO dbo.usuarios (usuario_id, nombre_usuario, email, pais, plan_suscripcion, fecha_alta)
            SELECT l.usuario_id, l.nombre_usuario, l.email, l.pais, l.plan_suscripcion, l.fecha_alta
            FROM #lote_usuarios AS l
            WHERE l.motivo IS NULL;

            SET @insertadas = @@ROWCOUNT;

        COMMIT;

        -- 4. Anotar el final correcto
        UPDATE dbo.log_cargas
        SET fin = SYSDATETIME(),
            filas_leidas = @leidas,
            filas_insertadas = @insertadas,
            filas_rechazadas = @rechazadas,
            estado = N'OK'
        WHERE log_id = @log_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        UPDATE dbo.log_cargas
        SET fin = SYSDATETIME(),
            filas_leidas = @leidas,
            estado = N'Error',
            mensaje_error = ERROR_MESSAGE()
        WHERE log_id = @log_id;

        THROW;
    END CATCH;
END;
GO

-- Dos ejecuciones seguidas (prueba de idempotencia)
EXEC dbo.usp_cargar_usuarios;
EXEC dbo.usp_cargar_usuarios;
GO

SELECT proceso, filas_leidas, filas_insertadas, filas_rechazadas, estado
FROM (SELECT TOP (2) * FROM dbo.log_cargas ORDER BY log_id DESC) AS t
ORDER BY log_id;

SELECT log_id, usuario_id, nombre_usuario, motivo
FROM dbo.rechazos_altas
ORDER BY log_id, usuario_id;

SELECT COUNT(*) AS usuarios FROM dbo.usuarios;
GO

-- Limpieza
DELETE FROM dbo.usuarios WHERE usuario_id > 10;
