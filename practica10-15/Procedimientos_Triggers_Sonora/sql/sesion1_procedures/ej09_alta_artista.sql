/* Sesión 1 · Ejercicio 9 · Alta de artista con validaciones y THROW */
USE SonoraDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_alta_artista
    @nombre      nvarchar(100),
    @pais        char(2),
    @genero      nvarchar(100),
    @artista_id  int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @genero_id int;

    BEGIN TRY
        SELECT @genero_id = genero_id
        FROM dbo.generos
        WHERE nombre = @genero;

        IF @genero_id IS NULL
            THROW 50010, N'El género indicado no existe.', 1;

        IF EXISTS (SELECT 1 FROM dbo.artistas WHERE nombre = @nombre)
            THROW 50011, N'Ya existe un artista con ese nombre.', 1;

        BEGIN TRAN;

            SELECT @artista_id = COALESCE(MAX(artista_id), 0) + 1
            FROM dbo.artistas WITH (UPDLOCK, HOLDLOCK);

            INSERT INTO dbo.artistas (artista_id, nombre, pais, genero_id)
            VALUES (@artista_id, @nombre, @pais, @genero_id);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        THROW;
    END CATCH;
END;
GO

-- Llamada 1: género inexistente  ->  Msg 50010
DECLARE @id int;
EXEC dbo.usp_alta_artista @nombre = N'Aurora Boreal', @pais = 'ES', @genero = N'Synthwave',
     @artista_id = @id OUTPUT;
SELECT @id AS artista_id;
GO

-- Llamada 2: correcta  ->  devuelve 10
DECLARE @id int;
EXEC dbo.usp_alta_artista @nombre = N'Aurora Boreal', @pais = 'ES', @genero = N'House',
     @artista_id = @id OUTPUT;
SELECT @id AS artista_id;

SELECT artista_id, nombre, pais, genero_id
FROM dbo.artistas
WHERE artista_id = @id;
GO

-- Llamada 3: repetida  ->  Msg 50011
DECLARE @id int;
EXEC dbo.usp_alta_artista @nombre = N'Aurora Boreal', @pais = 'ES', @genero = N'House',
     @artista_id = @id OUTPUT;
GO

-- Limpieza: conservar el punto de partida
DELETE FROM dbo.artistas WHERE artista_id > 9;
