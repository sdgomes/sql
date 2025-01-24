-- Identificar Bloqueios (Deadlocks e Lock Waits)

SELECT 
    blocking_session_id AS Sessão_Bloqueadora,
    session_id AS Sessão_Bloqueada,
    wait_type AS Tipo_Espera,
    wait_time AS Tempo_Espera,
    blocking_session_id AS ID_Bloqueador
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
ORDER BY wait_time DESC;

