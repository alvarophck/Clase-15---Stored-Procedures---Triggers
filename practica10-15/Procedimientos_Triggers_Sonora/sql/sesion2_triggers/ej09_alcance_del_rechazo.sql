/* Sesión 2 · Ejercicio 9 · Hasta dónde llega el THROW de un trigger
   Requiere el trigger del Ejercicio 7 activo. */
USE SonoraDB;
GO

/* ---------- a) Dentro de una transacción ----------
   Predicción: 0 transacciones abiertas y 9 artistas.
   El INSERT de la reproducción dispara el THROW, se deshace TODA la transacción
   (también el alta de Aurora Boreal) y el lote termina: ni el tercer INSERT ni el
   COMMIT llegan a ejecutarse. */
BEGIN TRAN;

    INSERT INTO dbo.artistas (artista_id, nombre, pais, genero_id)
    VALUES (10, N'Aurora Boreal', 'ES', 11);

    INSERT INTO dbo.reproducciones
        (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido)
    VALUES (47, 9, 103, '2026-09-20 10:00', 176, N'Web', N'Canción');

    INSERT INTO dbo.artistas (artista_id, nombre, pais, genero_id)
    VALUES (11, N'Trío Magnético', 'MX', 9);

COMMIT;
GO

SELECT @@TRANCOUNT AS transacciones_abiertas,
       (SELECT COUNT(*) FROM dbo.artistas) AS artistas;
GO

/* ---------- b) Sin transacción explícita ----------
   Predicción: 10 artistas.
   El primer INSERT se confirma solo (autocommit). El error del trigger deshace su
   propia instrucción y termina el lote, así que Trío Magnético no se inserta. */
INSERT INTO dbo.artistas (artista_id, nombre, pais, genero_id)
VALUES (10, N'Aurora Boreal', 'ES', 11);

INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido)
VALUES (47, 9, 103, '2026-09-20 10:00', 176, N'Web', N'Canción');

INSERT INTO dbo.artistas (artista_id, nombre, pais, genero_id)
VALUES (11, N'Trío Magnético', 'MX', 9);
GO

SELECT COUNT(*) AS artistas FROM dbo.artistas;
GO

DELETE FROM dbo.artistas WHERE artista_id > 9;
GO

/* ---------- c) Capturarlo con TRY ... CATCH ---------- */
BEGIN TRY
    INSERT INTO dbo.reproducciones
        (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido)
    VALUES (47, 9, 103, '2026-09-20 10:00', 176, N'Web', N'Canción');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    SELECT ERROR_NUMBER()    AS numero,
           ERROR_PROCEDURE() AS origen,
           ERROR_MESSAGE()   AS mensaje;
END CATCH;
