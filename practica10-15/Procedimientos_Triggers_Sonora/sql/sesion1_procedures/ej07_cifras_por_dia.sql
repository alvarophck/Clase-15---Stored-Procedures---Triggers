/* Sesión 1 · Ejercicio 7 · Cifras día a día con WHILE y parámetros OUTPUT */
USE SonoraDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_cifras_por_dia
    @desde  date,
    @hasta  date
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @resultado TABLE (
        dia             date          NOT NULL PRIMARY KEY,
        reproducciones  int           NOT NULL,
        minutos         decimal(8,1)  NOT NULL
    );

    DECLARE @dia date = @desde;
    DECLARE @dia_siguiente date;
    DECLARE @n int, @min decimal(8,1);

    WHILE @dia < @hasta
    BEGIN
        SET @dia_siguiente = DATEADD(DAY, 1, @dia);

        EXEC dbo.usp_cifras_periodo
             @desde = @dia,
             @hasta = @dia_siguiente,
             @reproducciones = @n OUTPUT,
             @minutos = @min OUTPUT;

        INSERT INTO @resultado (dia, reproducciones, minutos)
        VALUES (@dia, @n, @min);

        SET @dia = @dia_siguiente;
    END;

    SELECT dia, reproducciones, minutos
    FROM @resultado
    ORDER BY dia;
END;
GO

EXEC dbo.usp_cifras_por_dia @desde = '2026-09-20', @hasta = '2026-09-25';
