/* Sesión 1 · Ejercicio 8 · Predecir el resultado de un TRY ... CATCH */
USE SonoraDB;
GO

DROP TABLE IF EXISTS #pasos;

CREATE TABLE #pasos (
    paso   int           NOT NULL PRIMARY KEY,
    texto  nvarchar(30)  NOT NULL
);

BEGIN TRY
    INSERT INTO #pasos (paso, texto) VALUES (1, N'inicio');
    INSERT INTO #pasos (paso, texto) VALUES (2, NULL);
    INSERT INTO #pasos (paso, texto) VALUES (3, N'después del fallo');
END TRY
BEGIN CATCH
    INSERT INTO #pasos (paso, texto) VALUES (4, N'en el CATCH');

    IF ERROR_NUMBER() = 2627
        INSERT INTO #pasos (paso, texto) VALUES (5, N'clave duplicada');
        INSERT INTO #pasos (paso, texto) VALUES (6, N'¿y esta?');
END CATCH;

INSERT INTO #pasos (paso, texto) VALUES (7, N'fin del script');

SELECT paso, texto FROM #pasos ORDER BY paso;

/* Predicción: filas 1, 4, 6 y 7.
   - Paso 1: se inserta.
   - Paso 2: falla por NOT NULL (Msg 515, no 2627) y salta al CATCH.
   - Paso 3: no se ejecuta.
   - Paso 4: se inserta en el CATCH.
   - Paso 5: el IF compara con 2627 y el error es 515, así que no entra.
   - Paso 6: sin BEGIN ... END el IF solo controla el paso 5; el 6 se ejecuta siempre.
   - Paso 7: el CATCH no relanza el error, el script continúa.

   Con THROW; antes de END CATCH:
   tras insertar los pasos 4 y 6 se relanza el Msg 515. Como no hay otro TRY que lo
   recoja, el lote termina ahí: el paso 7 y el SELECT final no se ejecutan y el error
   aparece en rojo. #pasos queda con 1, 4 y 6 (se puede comprobar con un SELECT en
   otro lote). */
