-- Monitorar Consumo de Memória

SELECT TOP 10
    database_id AS DatabaseID,
    DB_NAME(database_id) AS DatabaseName,
    COUNT(*) * 8 / 1024 AS Memoria_MB
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY Memoria_MB DESC;
