/* Sesión 2 · Ejercicio 12 · Carga histórica con el trigger desactivado
   Requiere el trigger del Ejercicio 7. */
USE SonoraDB;
GO

/* ---------- a) Inventario de los triggers de reproducciones ---------- */
SELECT name, OBJECT_NAME(parent_id) AS sobre, is_instead_of_trigger, is_disabled
FROM sys.triggers
WHERE parent_id = OBJECT_ID(N'dbo.reproducciones');
GO

/* ---------- b) Desactivar y comprobar ---------- */
DISABLE TRIGGER dbo.trg_reproducciones_fecha_alta ON dbo.reproducciones;
GO

SELECT name, OBJECT_NAME(parent_id) AS sobre, is_disabled
FROM sys.triggers
WHERE name = N'trg_reproducciones_fecha_alta';
GO

/* ---------- c) Carga histórica ---------- */
INSERT INTO dbo.reproducciones
    (reproduccion_id, usuario_id, cancion_id, fecha_hora, segundos_escuchados, dispositivo, tipo_contenido) VALUES
(51, 6,  102, '2026-08-15 21:00', 201, N'Smart TV', N'Canción'),
(52, 10, 103, '2026-09-10 18:00', 176, N'Móvil',    N'Canción');
GO

/* ---------- d) Reactivar y comprobar ---------- */
ENABLE TRIGGER dbo.trg_reproducciones_fecha_alta ON dbo.reproducciones;
GO

SELECT name, OBJECT_NAME(parent_id) AS sobre, is_disabled
FROM sys.triggers
WHERE name = N'trg_reproducciones_fecha_alta';
GO
/* No protesta: ENABLE TRIGGER no revisa las filas que ya hay en la tabla. El trigger
   solo actúa sobre las inserciones que ocurran a partir de ahora. */

/* ---------- e) Filas que hoy incumplen la regla ---------- */
SELECT r.reproduccion_id, u.nombre_usuario, r.fecha_hora, u.fecha_alta
FROM dbo.reproducciones AS r
JOIN dbo.usuarios       AS u ON u.usuario_id = r.usuario_id
WHERE r.fecha_hora < u.fecha_alta
ORDER BY r.reproduccion_id;
GO

/* ---------- f) Respuesta ----------
   Una restricción (CHECK, FOREIGN KEY) garantiza que TODAS las filas de la tabla la
   cumplen: al crearla o reactivarla con WITH CHECK se comprueban también las filas
   existentes. El trigger solo garantiza que las filas que entran mientras está
   activo la cumplen; lo que entró con él desactivado se queda.
   Después de un mantenimiento así debería quedar anotado: quién lo autorizó (Raúl),
   quién lo ejecutó, cuándo se desactivó y se reactivó el trigger, qué filas se
   cargaron (51 y 52) y el motivo (reproducciones históricas de la plataforma
   comprada), para que nadie las tome por un fallo del trigger. Y comprobar en
   sys.triggers que is_disabled vuelve a 0. */

/* ---------- Limpieza ---------- */
DELETE FROM dbo.reproducciones WHERE reproduccion_id > 43;
DROP TRIGGER IF EXISTS dbo.trg_reproducciones_fecha_alta;
