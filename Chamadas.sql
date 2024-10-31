/** PROCEDURES */

-- Variável data é opcional
EXEC COMPARATIVO_INVENTARIO 
    @ENDERECO = 'WIP04XXX',
    @DATA = '2024-09-29 00:00:00.00'

EXEC TRUNCATE_SCHEMA_TABLES
    @TABLE_SCHEMATIC = 'XXX_'

EXEC DROP_SCHEMA_TABLES
    @TABLE_SCHEMATIC = 'XXX_'

EXEC JSON_CONTATOS_OUTLOOK 
    @JSON = 0
    
/** FUNÇÕES */

SELECT dbo.CONVERT_IMAGE(IMAGEM) FROM TEM_TABLE