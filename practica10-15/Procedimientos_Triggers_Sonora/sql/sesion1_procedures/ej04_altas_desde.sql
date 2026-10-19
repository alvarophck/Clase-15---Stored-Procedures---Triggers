/* Sesión 1 · Ejercicio 4 · Altas desde una fecha, con país opcional */
USE SonoraDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_altas_desde
    @desde  date,
    @pais   char(2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT nombre_usuario, pais, plan_suscripcion, fecha_alta
    FROM dbo.usuarios
    WHERE fecha_alta >= @desde
      AND (@pais IS NULL OR pais = @pais)
    ORDER BY fecha_alta, nombre_usuario;
END;
GO

EXEC dbo.usp_altas_desde @desde = '2026-01-01';

EXEC dbo.usp_altas_desde @desde = '2026-01-01', @pais = 'ES';
