SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CPUHeavyQueries
    @TopN INT = 10,            -- Número de queries mais pesadas a serem retornadas (padrão: 10)
    @DatabaseName SYSNAME = NULL -- Filtrar queries por banco de dados (opcional)
AS
BEGIN
    SET NOCOUNT ON;

    -- Garantir que @TopN seja um valor válido (>= 1)
    IF @TopN IS NULL OR @TopN <= 0
        SET @TopN = 10;

        SELECT TOP (@TopN)
            qs.execution_count AS [Execuções],
            qs.total_worker_time AS [Total de CPU Utilizado (ms)],
            qs.total_worker_time / NULLIF(qs.execution_count, 0) AS [Média de CPU por Execução (ms)],
            TRY_CAST(qt.text AS NVARCHAR(MAX)) AS [Query Texto]
        FROM sys.dm_exec_query_stats qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
        WHERE (@DatabaseName IS NULL OR DB_NAME(qt.dbid) = @DatabaseName) -- Filtrar por banco se informado
        ORDER BY [Total de CPU Utilizado (ms)] DESC;
END;
GO

EXEC sp_MS_marksystemobject 'sp_CPUHeavyQueries';
GO