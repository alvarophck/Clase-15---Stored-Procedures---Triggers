/* Sesión 1 · Ejercicio 12 · ¿Es idempotente? (análisis, sin ejecutar)

   A · NO idempotente. Debe arreglarse.
       La segunda ejecución intenta insertar los mismos días y falla con Msg 2627
       (resumen_diario tiene PRIMARY KEY en dia). Sin clave primaria duplicaría
       las filas en silencio.
       Arreglo: borrar el tramo antes de insertarlo (patrón de
       usp_refrescar_resumen_diario), o añadir WHERE NOT EXISTS.

   B · NO idempotente. Debe arreglarse.
       Cada ejecución suma otros 5 segundos: tras dos ejecuciones son 10.
       Arreglo: asignar el valor final y no un incremento relativo
       (SET duracion_seg = <valor correcto>), o condicionar la corrección a una
       marca que impida aplicarla dos veces (tabla de control de correcciones).

   C · Idempotente. Asigna un valor fijo: la segunda vez deja 'PR' igual que la
       primera.

   D · Idempotente. La segunda ejecución no encuentra filas que borrar y el
       estado final es el mismo.

   E · NO idempotente y NO debe arreglarse.
       Cada ejecución añade una fila al log, y eso es lo que se busca: el log
       cuenta ejecuciones, no datos.
*/

-- Ejemplo de arreglo para A
DELETE FROM dbo.resumen_diario
WHERE dia >= '2026-09-16' AND dia < '2026-09-23';

INSERT INTO dbo.resumen_diario (dia, reproducciones, oyentes, minutos)
SELECT CAST(fecha_hora AS date), COUNT(*), COUNT(DISTINCT usuario_id),
       CAST(SUM(segundos_escuchados) / 60.0 AS decimal(8,1))
FROM dbo.reproducciones
WHERE tipo_contenido = N'Canción' AND segundos_escuchados >= 30
  AND fecha_hora >= '2026-09-16' AND fecha_hora < '2026-09-23'
GROUP BY CAST(fecha_hora AS date);
