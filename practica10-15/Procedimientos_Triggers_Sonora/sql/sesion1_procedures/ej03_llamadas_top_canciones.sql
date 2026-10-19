/* Sesión 1 · Ejercicio 3 · Cinco llamadas a usp_top_canciones
   Ejecutar cada llamada POR SEPARADO (seleccionarla y F5). */
USE SonoraDB;
GO

-- a) Falta @hasta  ->  Msg 201 (expects parameter '@hasta', which was not supplied)
EXEC dbo.usp_top_canciones '2026-09-16';

-- b) Por nombre y en otro orden: válido. Solo plan Familiar  ->  2 filas
EXEC dbo.usp_top_canciones @plan = N'Familiar', @hasta = '2026-09-23', @desde = '2026-09-16';

-- c) El tercer valor por posición va a @top (int), no a @plan
--    ->  Msg 8114 (Error converting data type nvarchar to int)
EXEC dbo.usp_top_canciones '2026-09-16', '2026-09-23', N'Free';

-- d) Tras un parámetro por nombre no puede ir uno por posición
--    ->  Msg 119 (Must pass parameter number 2 and subsequent parameters as '@name = value')
EXEC dbo.usp_top_canciones @desde = '2026-09-16', '2026-09-23';

-- e) Fechas al revés: no hay error, pero ninguna fila cumple
--    fecha >= 23/09 y fecha < 16/09  ->  0 filas
EXEC dbo.usp_top_canciones '2026-09-23', '2026-09-16';
