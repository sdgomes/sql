SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CheckFragmentation
    @DatabaseName SYSNAME, -- Nome do banco de dados
    @TableName SYSNAME,    -- Nome da tabela a ser analisada
    @Mode NVARCHAR(10) = 'LIMITED' -- Modo de análise ('LIMITED', 'SAMPLED', 'DETAILED')
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar se o modo de análise é válido
    IF @Mode NOT IN ('LIMITED', 'SAMPLED', 'DETAILED')
    BEGIN
        PRINT 'Erro: O modo de análise deve ser LIMITED, SAMPLED ou DETAILED.';
        RETURN;
    END;

    -- Verificar se a tabela existe no banco informado
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'
    USE ' + QUOTENAME(@DatabaseName) + N';

    IF NOT EXISTS (
        SELECT 1 FROM sys.tables WHERE name = ' + QUOTENAME(@TableName, '''') + N'
    )
    BEGIN
        PRINT ''Erro: A tabela especificada não existe no banco de dados informado.'';
        RETURN;
    END;';

    EXEC sp_executesql @SQL;

    -- Executar análise de fragmentação
    SET @SQL = N'
    USE ' + QUOTENAME(@DatabaseName) + N';

    SELECT 
        s.[name] AS SchemaName, 
        t.[name] AS TableName, 
        i.[name] AS IndexName, 
        ps.index_type_desc, 
        ps.avg_fragmentation_in_percent,
        CASE 
            WHEN ps.avg_fragmentation_in_percent < 5 THEN ''Índice está OK''
            WHEN ps.avg_fragmentation_in_percent BETWEEN 5 AND 30 THEN ''Reorganizar índice''
            WHEN ps.avg_fragmentation_in_percent > 30 THEN ''Reconstruir índice''
        END AS AcaoRecomendada
    FROM sys.dm_db_index_physical_stats(
        DB_ID(), 
        OBJECT_ID(''' + @TableName + N'''), 
        NULL, NULL, ''' + @Mode + N'''
    ) ps
    JOIN sys.tables t ON t.[object_id] = ps.[object_id]
    JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
    JOIN sys.indexes i ON i.[object_id] = t.[object_id] 
        AND ps.[index_id] = i.[index_id]
    WHERE ps.index_type_desc <> ''HEAP'' 
    ORDER BY ps.avg_fragmentation_in_percent DESC;';

    EXEC sp_executesql @SQL;
END;
GO

EXEC sp_MS_marksystemobject 'sp_CheckFragmentation';
GO
