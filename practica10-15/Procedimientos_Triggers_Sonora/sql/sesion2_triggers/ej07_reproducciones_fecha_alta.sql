/* Sesión 2 · Ejercicio 7 · Reproducciones anteriores al alta del usuario
   NO borrar el trigger: lo usan los ejercicios 9 y 12. */
USE SonoraDB;
GO

CREATE OR ALTER TRIGGER dbo.trg_reproducciones_fecha_alta
ON dbo.reproducciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1
               FROM inserted AS i
               JOIN dbo.usuarios AS u ON u.usuario_id = i.usuario_id
               WHERE i.fecha_hora < u.fecha_alta)
        THROW 50130, N'Hay reproducciones anteriores a la fecha de alta de su usuario.', 1;
END;
GO

-- a) pau.synth se dio de alta el 21/09  ->  Msg 50130
INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido)
VALUES (44, 9, 103, '2026-09-20 10:00', 176, N'Web', N'Canción');
GO
SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;
GO

-- b) Una fila mala tumba a las dos buenas  ->  Msg 50130
INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido) VALUES
(44, 6,  101, '2026-09-23 09:00', 185, N'Smart TV', N'Canción'),
(45, 10, 113, '2026-09-20 23:50', 158, N'Móvil',    N'Canción'),
(46, 2,  107, '2026-09-23 10:00', 198, N'Web',      N'Canción');
GO
SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;
GO

-- c) Solo las buenas  ->  (2 rows affected)
INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido) VALUES
(44, 6,  101, '2026-09-23 09:00', 185, N'Smart TV', N'Canción'),
(46, 2,  107, '2026-09-23 10:00', 198, N'Web',      N'Canción');
GO
SELECT COUNT(*) AS reproducciones FROM dbo.reproducciones;
