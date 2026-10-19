/* Sesión 2 · Ejercicio 8 · ¿Restricción o trigger? (análisis, sin ejecutar)

   a) Segundos no negativos             -> Restricción CHECK (segundos_escuchados >= 0).
                                            Solo mira una columna de su propia fila.
   b) Email único                       -> Restricción UNIQUE (email).
   c) Canción con artista existente     -> FOREIGN KEY (artista_id) REFERENCES artistas.
   d) Reproducción no anterior al alta  -> Trigger. Compara con otra tabla (usuarios),
                                            y un CHECK solo ve su propia fila.
   e) Plan en una lista                 -> Restricción CHECK (plan_suscripcion IN
                                            (N'Free', N'Premium', N'Familiar')).
   f) Anotar cada cambio de país        -> Trigger AFTER UPDATE con inserted/deleted.
                                            Una restricción no escribe en otra tabla.
   g) Duración no baja más de un 10 %   -> Trigger. Regla de transición: necesita el
                                            valor anterior (deleted), que un CHECK no ve.
   h) Título obligatorio                -> Restricción NOT NULL (más un CHECK si
                                            tampoco se admite la cadena vacía).

   Resultado: 5 restricciones (a, b, c, e, h) y 3 triggers (d, f, g).
*/
