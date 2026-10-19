/* Sesión 2 · Ejercicio 11 · Trigger DDL sobre vistas */
USE SonoraDB;
GO

DROP TABLE IF EXISTS dbo.log_vistas;

CREATE TABLE dbo.log_vistas (
    cambio_id   int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    fecha       datetime2(0)   NOT NULL DEFAULT SYSDATETIME(),
    usuario_bd  nvarchar(128)  NOT NULL DEFAULT USER_NAME(),
    evento      nvarchar(100)  NOT NULL,
    vista       nvarchar(128)  NULL
);
GO

/* ---------- a) ---------- */
CREATE OR ALTER TRIGGER trg_ddl_vistas
ON DATABASE
AFTER CREATE_VIEW, ALTER_VIEW, DROP_VIEW      -- equivale a DDL_VIEW_EVENTS
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @datos xml = EVENTDATA();

    INSERT INTO dbo.log_vistas (evento, vista)
    VALUES (@datos.value('(/EVENT_INSTANCE/EventType)[1]',  'nvarchar(100)'),
            @datos.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(128)'));
END;
GO

CREATE VIEW dbo.v_prueba_ddl
AS
SELECT usuario_id, nombre_usuario FROM dbo.usuarios;
GO

CREATE OR ALTER VIEW dbo.v_prueba_ddl
AS
SELECT usuario_id, nombre_usuario, pais FROM dbo.usuarios;
GO

DROP VIEW dbo.v_prueba_ddl;
GO

SELECT cambio_id, fecha, usuario_bd, evento, vista
FROM dbo.log_vistas
ORDER BY cambio_id;
GO

/* ---------- b) Respuesta ----------
   El trigger seguiría disparándose con cada CREATE, ALTER o DROP VIEW, pero su
   INSERT fallaría con Msg 208 (Invalid object name 'dbo.log_vistas'). Como el
   trigger trabaja en la transacción de la instrucción DDL, el error la deshace:
   nadie podría crear, modificar ni borrar ninguna vista en SonoraDB hasta recrear la
   tabla o borrar (o desactivar) el trigger. */

/* ---------- c) ---------- */
DROP TRIGGER IF EXISTS trg_ddl_vistas ON DATABASE;
