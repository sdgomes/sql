USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_Kills]    Script Date: 20/12/2024 14:14:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_Kills]
    @session_ids NVARCHAR(MAX) -- Lista de IDs no formato '1, 2, 3, 4'
AS
BEGIN
    SET NOCOUNT ON;

    -- Variáveis locais
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ID NVARCHAR(10);
    DECLARE @Cursor CURSOR;

    -- Preparar a string SQL
    SET @SQL = 'SELECT value FROM STRING_SPLIT(''' + @session_ids + ''', '','')';

    -- Criar uma tabela temporária para armazenar os IDs
    CREATE TABLE #SessionList (SessionID NVARCHAR(10));

    -- Inserir os IDs na tabela temporária
    INSERT INTO #SessionList (SessionID)
    EXEC sp_executesql @SQL;

    -- Criar o cursor para iterar pelos IDs
    SET @Cursor = CURSOR FOR
    SELECT SessionID FROM #SessionList;

    OPEN @Cursor;
    FETCH NEXT FROM @Cursor INTO @ID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Executar o comando KILL para cada ID
            EXEC ('KILL ' + @ID);
            PRINT 'Sessão ' + @ID + ' encerrada com sucesso.';
        END TRY
        BEGIN CATCH
            PRINT 'Erro ao encerrar a sessão ' + @ID + ': ' + ERROR_MESSAGE();
        END CATCH

        FETCH NEXT FROM @Cursor INTO @ID;
    END

    CLOSE @Cursor;
    DEALLOCATE @Cursor;

    -- Limpar a tabela temporária
    DROP TABLE #SessionList;

    SET NOCOUNT OFF;
END

EXEC sp_MS_marksystemobject 'sp_WhoIsActive';