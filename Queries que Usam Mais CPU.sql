-- Identificar Queries que Usam Mais CPU

SELECT 
    r.session_id AS SessaoID,
    s.host_name AS HostName,
    s.program_name AS ProgramaOrigem,
    s.login_name AS Usuario,
    r.status AS StatusExecucao,
    qs.execution_count AS Execucoes,
    qs.total_worker_time / qs.execution_count AS Tempo_Medio_CPU,
    qs.total_worker_time AS Tempo_Total_CPU,
    SUBSTRING(qt.text, (qs.statement_start_offset / 2) + 1, 
              ((CASE qs.statement_end_offset WHEN -1 
                   THEN DATALENGTH(qt.text) 
                   ELSE qs.statement_end_offset 
               END - qs.statement_start_offset) / 2) + 1) AS QueryTexto
FROM sys.dm_exec_requests r
RIGHT JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
RIGHT JOIN sys.dm_exec_query_stats qs ON r.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY Execucoes DESC, Tempo_Total_CPU DESC;
