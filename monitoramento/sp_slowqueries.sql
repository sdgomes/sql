SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_SlowQueries
    @TopN INT = 10 -- Número de queries mais lentas a serem retornadas (padrão = 10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Garantir que @TopN seja um valor válido (>= 1)
    IF @TopN IS NULL OR @TopN <= 0
        SET @TopN = 10;

    -- Captura as queries mais lentas
    SELECT TOP (@TopN)
        r.session_id AS SessaoID,
        s.host_name AS HostName,
        s.program_name AS ProgramaOrigem,
        s.login_name AS Usuario,
        r.status AS StatusExecucao,
        qs.execution_count AS Execucoes,
        qs.total_worker_time / NULLIF(qs.execution_count, 0) AS Tempo_Medio_CPU,
        qs.total_elapsed_time / NULLIF(qs.execution_count, 0) AS Tempo_Medio_Execucao,
        qs.total_logical_reads / NULLIF(qs.execution_count, 0) AS Leituras_Medias,
        qs.total_physical_reads / NULLIF(qs.execution_count, 0) AS Leituras_Fisicas_Medias,
        TRY_CAST(
            SUBSTRING(qt.text, 
                      (qs.statement_start_offset / 2) + 1,
                      ((CASE qs.statement_end_offset WHEN -1 
                           THEN DATALENGTH(qt.text)
                           ELSE qs.statement_end_offset 
                       END - qs.statement_start_offset) / 2) + 1) 
            AS NVARCHAR(MAX)
        ) AS QueryTexto
    FROM sys.dm_exec_query_stats qs
    LEFT JOIN sys.dm_exec_requests r ON qs.plan_handle = r.plan_handle
    LEFT JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
    ORDER BY Tempo_Medio_Execucao DESC, Leituras_Medias DESC;
END;
GO

EXEC sp_MS_marksystemobject 'sp_SlowQueries';
GO