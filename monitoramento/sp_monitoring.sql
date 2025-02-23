SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Monitoring
AS
BEGIN
    SET NOCOUNT ON;

    -- Lista de Procedures com chamadas e parâmetros opcionais
    DECLARE @Procedures TABLE (ProcName SYSNAME, ExecExample NVARCHAR(200), OptionalParams NVARCHAR(300));
    INSERT INTO @Procedures (ProcName, ExecExample, OptionalParams)
    VALUES 
        ('sp_blockmonitoring', 
         'EXEC sp_blockmonitoring', 
         '@DatabaseName (NVARCHAR) - Filtrar queries por banco de dados, @SessionID (INT) - Filtra por sessão específica'),

        ('sp_checkfragmentation', 
         'EXEC sp_checkfragmentation @DatabaseName = ''MeuBanco'', @TableName = ''MinhaTabela''', 
         '@Mode (NVARCHAR) - Pode ser ''LIMITED'', ''SAMPLED'' ou ''DETAILED'', padrão ''LIMITED'''),

        ('sp_CPUheavyqueries', 
         'EXEC sp_CPUheavyqueries', 
         '@TopN (INT) - Número de queries mais pesadas a serem retornadas, padrão 10, @DatabaseName (NVARCHAR) - Filtrar queries por banco de dados'),

        ('sp_kills', 
         'EXEC sp_kills ''N''', 
         'Nenhum parâmetro opcional'),

        ('sp_slowqueries', 
         'EXEC sp_slowqueries', 
         '@TopN (INT) - Número de queries mais lentas a retornar, padrão 10'),

        ('sp_whoisactive', 
         'EXEC sp_whoisactive', 
         'Nenhum parâmetro opcional'), 
    
        ('sp_userroleserver', 
         'EXEC sp_userroleserver', 
         'Nenhum parâmetro opcional'), 

        ('sp_userroledatabase', 
         'EXEC sp_userroledatabase', 
         'Nenhum parâmetro opcional');

    -- Criar tabela temporária para armazenar os resultados
    CREATE TABLE #Results (
        ProcName SYSNAME,
        Existe BIT,
        QueryText NVARCHAR(200),
        OptionalParams NVARCHAR(300)
    );

    DECLARE @ProcName SYSNAME, @Exists BIT, @QueryText NVARCHAR(200), @OptionalParams NVARCHAR(300);

    DECLARE cur CURSOR FOR 
    SELECT ProcName, ExecExample, OptionalParams FROM @Procedures;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ProcName, @QueryText, @OptionalParams;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar se a Procedure existe
        SET @Exists = CASE WHEN OBJECT_ID(@ProcName, 'P') IS NOT NULL THEN 1 ELSE 0 END;

        -- Se não existir, marcar a chamada como "NÃO EXISTE"
        IF @Exists = 0
        BEGIN
            SET @QueryText = NULL;
            SET @OptionalParams = NULL;
        END

        -- Inserir os dados na tabela temporária
        INSERT INTO #Results (ProcName, Existe, QueryText, OptionalParams)
        VALUES (@ProcName, @Exists, @QueryText, @OptionalParams);

        FETCH NEXT FROM cur INTO @ProcName, @QueryText, @OptionalParams;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Exibir os resultados
    SELECT 
        ProcName AS [Nome Procedure],
        Existe,
        QueryText AS [Chamada Padrão],
        OptionalParams AS [Parâmetros Opcionais]
    FROM #Results;

    -- Limpar tabela temporária
    DROP TABLE #Results;
END;
GO

-- Tornar a procedure acessível globalmente
EXEC sp_MS_marksystemobject 'sp_Monitoring';
GO
