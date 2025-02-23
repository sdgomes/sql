SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_Kills]
    @session_ids NVARCHAR(MAX) -- Lista de IDs no formato '1,2,3,4'
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica se a tabela temporária já existe e a remove
    IF OBJECT_ID('tempdb..#SessionList') IS NOT NULL
        DROP TABLE #SessionList;

    -- Criar uma tabela temporária para armazenar os IDs
    CREATE TABLE #SessionList (SessionID INT);

    -- Inserir os IDs na tabela temporária, convertendo para INT
    INSERT INTO #SessionList (SessionID)
    SELECT TRY_CAST(value AS INT) 
    FROM STRING_SPLIT(@session_ids, ',')
    WHERE TRY_CAST(value AS INT) IS NOT NULL; -- Garante que apenas valores inteiros válidos sejam inseridos

    -- Variável para armazenar o ID atual
    DECLARE @ID INT;
    DECLARE @SQL NVARCHAR(50); -- Variável para armazenar o comando KILL

    -- Processar cada sessão da tabela temporária
    WHILE EXISTS (SELECT 1 FROM #SessionList)
    BEGIN
        -- Seleciona e remove um ID por vez
        SELECT TOP 1 @ID = SessionID FROM #SessionList;
        DELETE FROM #SessionList WHERE SessionID = @ID;

        -- Verifica se a sessão existe antes de tentar encerrar
        IF EXISTS (SELECT 1 FROM sys.dm_exec_sessions WHERE session_id = @ID)
        BEGIN TRY
            -- Construção correta do comando KILL
            SET @SQL = 'KILL ' + CAST(@ID AS NVARCHAR(10));
            EXEC sp_executesql @SQL;
            PRINT 'Sessão ' + CAST(@ID AS NVARCHAR(10)) + ' encerrada com sucesso.';
        END TRY
        BEGIN CATCH
            PRINT 'Erro ao encerrar a sessão ' + CAST(@ID AS NVARCHAR(10)) + ': ' + ERROR_MESSAGE();
        END CATCH;
    END

    -- Remover a tabela temporária ao final
    DROP TABLE #SessionList;
    
    SET NOCOUNT OFF;
END
GO

-- Torna a procedure um objeto do sistema
EXEC sp_MS_marksystemobject 'sp_Kills';
GO