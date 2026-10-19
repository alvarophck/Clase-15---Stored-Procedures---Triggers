/* Sesión 2 · Ejercicio 4 · Historial de cambios de puesto */
USE SonoraDB;
GO

DROP TABLE IF EXISTS dbo.historial_puestos;

CREATE TABLE dbo.historial_puestos (
    cambio_id        int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    empleado_id      int            NOT NULL,
    puesto_anterior  nvarchar(50)   NOT NULL,
    puesto_nuevo     nvarchar(50)   NOT NULL,
    fecha_cambio     datetime2(0)   NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE OR ALTER TRIGGER dbo.trg_empleados_historial_puestos
ON dbo.empleados
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(puesto)
        RETURN;

    INSERT INTO dbo.historial_puestos (empleado_id, puesto_anterior, puesto_nuevo)
    SELECT i.empleado_id, d.puesto, i.puesto
    FROM inserted AS i
    JOIN deleted  AS d ON d.empleado_id = i.empleado_id
    WHERE i.puesto <> d.puesto;
END;
GO

-- Promoción de los dos Data Engineer
UPDATE dbo.empleados SET puesto = N'Senior Data Engineer' WHERE puesto = N'Data Engineer';

-- Reorganización: no menciona el puesto
UPDATE dbo.empleados SET jefe_id = 2 WHERE nombre = N'Carmen Lozano';

-- Menciona el puesto pero no lo cambia
UPDATE dbo.empleados SET puesto = puesto;

SELECT empleado_id, puesto_anterior, puesto_nuevo, fecha_cambio
FROM dbo.historial_puestos
ORDER BY empleado_id;
GO

-- Limpieza (enunciado)
DROP TRIGGER IF EXISTS dbo.trg_empleados_historial_puestos;

UPDATE dbo.empleados SET puesto = N'Data Engineer' WHERE empleado_id IN (5, 6);
UPDATE dbo.empleados SET jefe_id = 4 WHERE empleado_id = 7;
