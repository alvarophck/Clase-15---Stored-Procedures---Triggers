/* Sesión 1 · Ejercicio 10 · Baja de usuario: de transacción falsa a plantilla */
USE SonoraDB;
GO

/* ---------- Versión de Hugo (enunciado) ---------- */
DROP TABLE IF EXISTS dbo.bajas_usuarios;

CREATE TABLE dbo.bajas_usuarios (
    usuario_id      int           NOT NULL PRIMARY KEY,
    nombre_usuario  nvarchar(50)  NOT NULL,
    motivo          nvarchar(30)  NOT NULL,
    fecha_baja      datetime2(0)  NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_bajas_usuarios_motivo
        CHECK (motivo IN (N'Solicitud del usuario', N'Impago', N'Fraude'))
);
GO

CREATE OR ALTER PROCEDURE dbo.usp_baja_usuario
    @nombre_usuario  nvarchar(50),
    @motivo          nvarchar(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @usuario_id int;

    SET @usuario_id = (SELECT usuario_id FROM dbo.usuarios WHERE nombre_usuario = @nombre_usuario);

    BEGIN TRAN;

        DELETE FROM dbo.reproducciones
        WHERE usuario_id = @usuario_id;

        INSERT INTO dbo.bajas_usuarios (usuario_id, nombre_usuario, motivo)
        VALUES (@usuario_id, @nombre_usuario, @motivo);

        DELETE FROM dbo.usuarios
        WHERE usuario_id = @usuario_id;

    COMMIT;
END;
GO

/* ---------- a) Motivo no admitido con la versión de Hugo ---------- */
EXEC dbo.usp_baja_usuario @nombre_usuario = N'pau.synth', @motivo = N'Se ha cansado';
GO

SELECT (SELECT COUNT(*) FROM dbo.reproducciones) AS reproducciones,
       (SELECT COUNT(*) FROM dbo.usuarios)       AS usuarios,
       (SELECT COUNT(*) FROM dbo.bajas_usuarios) AS bajas;
GO
/* Resultado: 41 · 9 · 0.
   El INSERT en bajas_usuarios falla por el CHECK (Msg 547), pero solo se anula esa
   instrucción. Sin XACT_ABORT ni TRY ... CATCH la ejecución sigue: el DELETE de
   usuarios funciona (sus reproducciones ya se habían borrado) y el COMMIT confirma
   los dos DELETE. El usuario y sus 2 reproducciones han desaparecido sin dejar
   constancia de la baja. */

/* ---------- b) Ejecutar el script del punto de partida de la Sesión 1 ---------- */

/* ---------- c) Versión con la plantilla de la sección 5 ---------- */
CREATE OR ALTER PROCEDURE dbo.usp_baja_usuario
    @nombre_usuario  nvarchar(50),
    @motivo          nvarchar(30)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @usuario_id int;

    BEGIN TRY
        SELECT @usuario_id = usuario_id
        FROM dbo.usuarios
        WHERE nombre_usuario = @nombre_usuario;

        IF @usuario_id IS NULL
            THROW 50020, N'El usuario no existe.', 1;

        BEGIN TRAN;

            DELETE FROM dbo.reproducciones
            WHERE usuario_id = @usuario_id;

            INSERT INTO dbo.bajas_usuarios (usuario_id, nombre_usuario, motivo)
            VALUES (@usuario_id, @nombre_usuario, @motivo);

            DELETE FROM dbo.usuarios
            WHERE usuario_id = @usuario_id;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        THROW;
    END CATCH;
END;
GO

EXEC dbo.usp_baja_usuario @nombre_usuario = N'pau.synth', @motivo = N'Se ha cansado';
GO

SELECT (SELECT COUNT(*) FROM dbo.reproducciones) AS reproducciones,
       (SELECT COUNT(*) FROM dbo.usuarios)       AS usuarios,
       (SELECT COUNT(*) FROM dbo.bajas_usuarios) AS bajas;
GO
/* Resultado: 43 · 10 · 0. El Msg 547 salta al CATCH, el ROLLBACK deshace el
   borrado de reproducciones y el THROW devuelve el error original. */

/* ---------- d) Motivo admitido ---------- */
EXEC dbo.usp_baja_usuario @nombre_usuario = N'pau.synth', @motivo = N'Solicitud del usuario';
GO

SELECT (SELECT COUNT(*) FROM dbo.reproducciones) AS reproducciones,
       (SELECT COUNT(*) FROM dbo.usuarios)       AS usuarios,
       (SELECT COUNT(*) FROM dbo.bajas_usuarios) AS bajas;
GO
/* Resultado: 41 · 9 · 1.
   Después, volver a ejecutar el script del punto de partida de la Sesión 1. */
