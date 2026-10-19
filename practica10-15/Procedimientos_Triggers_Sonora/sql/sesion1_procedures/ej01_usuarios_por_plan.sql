/* Sesión 1 · Ejercicio 1 · Usuarios por plan */
USE SonoraDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_usuarios_por_plan
AS
BEGIN
    SET NOCOUNT ON;

    SELECT plan_suscripcion, COUNT(*) AS usuarios
    FROM dbo.usuarios
    GROUP BY plan_suscripcion
    ORDER BY usuarios DESC, plan_suscripcion;
END;
GO

EXEC dbo.usp_usuarios_por_plan;
