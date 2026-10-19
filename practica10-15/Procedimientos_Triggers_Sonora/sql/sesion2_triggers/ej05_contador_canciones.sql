/* Sesión 2 · Ejercicio 5 · El contador de Pablo */
USE SonoraDB;
GO

/* ---------- Script de Pablo ---------- */
DROP TABLE IF EXISTS dbo.contador_canciones;

SELECT c.cancion_id,
       (SELECT COUNT(*) FROM dbo.reproducciones AS r WHERE r.cancion_id = c.cancion_id) AS total
INTO dbo.contador_canciones
FROM dbo.canciones AS c;
GO

CREATE OR ALTER TRIGGER dbo.trg_reproducciones_contador
ON dbo.reproducciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.contador_canciones
    SET total = total + 1
    WHERE cancion_id = (SELECT cancion_id FROM inserted);
END;
GO

-- Consulta de control que se repite en cada apartado
-- SELECT cancion_id, total FROM dbo.contador_canciones WHERE cancion_id IN (103, 108);
-- SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;

/* ---------- a) Una fila ---------- */
INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido)
VALUES (44, 1, 103, '2026-09-23 08:00', 176, N'Móvil', N'Canción');
GO

SELECT cancion_id, total FROM dbo.contador_canciones WHERE cancion_id IN (103, 108);
SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;
GO

/* ---------- b) Cuatro filas ---------- */
INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido) VALUES
(45, 4, 103,  '2026-09-23 09:00', 176, N'Móvil',      N'Canción'),
(46, 6, 103,  '2026-09-23 09:30', 176, N'Smart TV',   N'Canción'),
(47, 3, 108,  '2026-09-23 10:00', 167, N'Escritorio', N'Canción'),
(48, 5, NULL, '2026-09-23 10:05', 30,  N'Móvil',      N'Anuncio');
GO

SELECT cancion_id, total FROM dbo.contador_canciones WHERE cancion_id IN (103, 108);
SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;
GO
/* Error Msg 512 (Subquery returned more than 1 value). La subconsulta
   (SELECT cancion_id FROM inserted) devuelve 4 valores y no puede compararse con
   "=". El trigger falla y, como trabaja en la transacción del INSERT, se deshace
   también el INSERT: no entra ninguna de las cuatro filas. Siguen 44. */

/* ---------- c) Trigger reescrito para conjuntos ---------- */
CREATE OR ALTER TRIGGER dbo.trg_reproducciones_contador
ON dbo.reproducciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE cc
    SET total = cc.total + n.filas
    FROM dbo.contador_canciones AS cc
    JOIN (SELECT cancion_id, COUNT(*) AS filas
          FROM inserted
          WHERE cancion_id IS NOT NULL
          GROUP BY cancion_id) AS n
      ON n.cancion_id = cc.cancion_id;
END;
GO

INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido) VALUES
(45, 4, 103,  '2026-09-23 09:00', 176, N'Móvil',      N'Canción'),
(46, 6, 103,  '2026-09-23 09:30', 176, N'Smart TV',   N'Canción'),
(47, 3, 108,  '2026-09-23 10:00', 167, N'Escritorio', N'Canción'),
(48, 5, NULL, '2026-09-23 10:05', 30,  N'Móvil',      N'Anuncio');
GO

SELECT cancion_id, total FROM dbo.contador_canciones WHERE cancion_id IN (103, 108);
SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;
GO

/* ---------- d) Borrar las reproducciones de prueba ---------- */
DELETE FROM dbo.reproducciones WHERE reproduccion_id > 43;
GO

SELECT cc.cancion_id,
       cc.total AS total_contador,
       (SELECT COUNT(*) FROM dbo.reproducciones AS r WHERE r.cancion_id = cc.cancion_id) AS total_real
FROM dbo.contador_canciones AS cc
WHERE cc.cancion_id IN (103, 108);

SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;
GO
/* El contador marca 10 para Perreo Lunar y en realidad tiene 7. El trigger solo
   atiende a INSERT: los borrados (y los UPDATE que cambian cancion_id) no se
   restan. Un total mantenido por trigger se descuadra en cuanto falta un caso, y el
   descuadre no se corrige solo. Para un resumen así es más fiable un procedimiento
   que recalcule desde la tabla de origen. */

DROP TRIGGER IF EXISTS dbo.trg_reproducciones_contador;
DROP TABLE IF EXISTS dbo.contador_canciones;
