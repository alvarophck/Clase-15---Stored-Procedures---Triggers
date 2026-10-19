/* Sesión 2 · Ejercicio 10 · INSTEAD OF INSERT: ninguna fila tumba a las demás */
USE SonoraDB;
GO

DROP TABLE IF EXISTS dbo.altas_web;
DROP TABLE IF EXISTS dbo.altas_web_rechazadas;

CREATE TABLE dbo.altas_web (
    email             nvarchar(150)  NOT NULL PRIMARY KEY,
    pais              char(2)        NOT NULL,
    plan_suscripcion  nvarchar(20)   NOT NULL
        CHECK (plan_suscripcion IN (N'Free', N'Premium', N'Familiar')),
    fecha_registro    datetime2(0)   NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE dbo.altas_web_rechazadas (
    email             nvarchar(150)  NULL,
    pais              char(2)        NULL,
    plan_suscripcion  nvarchar(20)   NULL,
    motivo            nvarchar(60)   NOT NULL,
    fecha             datetime2(0)   NOT NULL DEFAULT SYSDATETIME()
);
GO

/* ---------- a) Sin trigger ----------
   Msg 547 (CHECK): Family y Premiun no son válidos. La instrucción se anula entera,
   también la fila correcta de teo.bass. altas_web queda con 0 filas. */
INSERT INTO dbo.altas_web (email, pais, plan_suscripcion) VALUES
(N'teo.bass@mail.com',  'ES', N'Free'),
(N'ines.wave@mail.com', 'CO', N'Family'),
(N'rober.mx@mail.com',  'MX', N'Premiun');
GO

SELECT COUNT(*) AS filas_altas_web FROM dbo.altas_web;
GO

/* ---------- b) Trigger INSTEAD OF INSERT ---------- */
CREATE OR ALTER TRIGGER dbo.trg_altas_web_entrada
ON dbo.altas_web
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Lote con el plan corregido y el motivo de rechazo, en orden de controles
    SELECT x.email, x.pais, x.plan_suscripcion,
           CASE
               WHEN x.plan_suscripcion NOT IN (N'Free', N'Premium', N'Familiar')
                   THEN N'Plan no reconocido'
               WHEN EXISTS (SELECT 1 FROM dbo.altas_web AS a WHERE a.email = x.email)
                   THEN N'Email ya registrado'
           END AS motivo
    INTO #entrada
    FROM (
        SELECT i.email, i.pais,
               CASE i.plan_suscripcion
                   WHEN N'Family' THEN N'Familiar'
                   WHEN N'Gratis' THEN N'Free'
                   ELSE i.plan_suscripcion
               END AS plan_suscripcion
        FROM inserted AS i
    ) AS x;

    INSERT INTO dbo.altas_web_rechazadas (email, pais, plan_suscripcion, motivo)
    SELECT email, pais, plan_suscripcion, motivo
    FROM #entrada
    WHERE motivo IS NOT NULL;

    -- Esta escritura en la propia tabla no vuelve a disparar el trigger
    INSERT INTO dbo.altas_web (email, pais, plan_suscripcion)
    SELECT email, pais, plan_suscripcion
    FROM #entrada
    WHERE motivo IS NULL;
END;
GO

/* ---------- c) Repetir el primer lote y cargar el segundo ---------- */
INSERT INTO dbo.altas_web (email, pais, plan_suscripcion) VALUES
(N'teo.bass@mail.com',  'ES', N'Free'),
(N'ines.wave@mail.com', 'CO', N'Family'),
(N'rober.mx@mail.com',  'MX', N'Premiun');
GO

INSERT INTO dbo.altas_web (email, pais, plan_suscripcion) VALUES
(N'teo.bass@mail.com', 'ES', N'Premium'),
(N'lola.pop@mail.com', 'ES', N'Gratis');
GO

SELECT email, pais, plan_suscripcion
FROM dbo.altas_web
ORDER BY email;

SELECT email, pais, plan_suscripcion, motivo
FROM dbo.altas_web_rechazadas
ORDER BY email;
