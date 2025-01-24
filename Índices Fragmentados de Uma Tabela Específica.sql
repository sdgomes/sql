-- Verificar Índices Fragmentados de Uma Tabela Específica

SELECT 
    dbschemas.[name] AS SchemaName, 
    dbtables.[name] AS TableName, 
    dbindexes.[name] AS IndexName, 
    indexstats.index_type_desc, 
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.SD3010'), NULL, NULL, 'LIMITED') indexstats
JOIN sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
JOIN sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
JOIN sys.indexes dbindexes ON dbindexes.[object_id] = dbtables.[object_id] 
    AND indexstats.[index_id] = dbindexes.[index_id]
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent DESC;