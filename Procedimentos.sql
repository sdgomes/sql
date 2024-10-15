USE [BASE DE DADOS]
GO

CREATE OR ALTER PROCEDURE [dbo].[COMPARATIVO_INVENTARIO] 
    @ENDERECO VARCHAR(255),
    @DATA VARCHAR(255) = '' 
AS
    IF @DATA = ''
        SET @DATA = GETDATE()

    IF @ENDERECO = ''
        BEGIN
            PRINT 'Por favor informe o endereço que você deseja consultar, para o comparativo. Variável, @ENDERECO'  
            RETURN 
        END

    BEGIN
        DECLARE @PDG_CODIGO VARCHAR(255) = (
            SELECT PDG_CODIGO FROM PDG010 
            WHERE PDG_DATLID = FORMAT(CAST(@DATA AS datetime), 'yyyyMMdd') AND 
                PDG_ENDER = @ENDERECO GROUP BY PDG_CODIGO
        )

        DECLARE @SOMA FLOAT = (SELECT SUM(PDG_QTINV1) AS SOMA FROM PDG010 WHERE PDG_CODIGO = @PDG_CODIGO)

        IF @SOMA IS NULL
            PRINT CONCAT('Não existe inventario para ser analisado na data informada: ', @DATA)
        ELSE
            SELECT 
                (SELECT SUM(BF_QUANT) AS QNT FROM SBF010 WHERE BF_LOCALIZ = @ENDERECO AND BF_QUANT > 0 AND D_E_L_E_T_ = '') AS 'QNT. ENDERECAMENTO',
                @SOMA AS 'SOMA DO QUE FOI LIDO'

    END       
GO

USE [BASE DE DADOS]
GO

CREATE OR ALTER PROCEDURE [dbo].[TRUNCATE_SCHEMA_TABLES] @TABLE_SCHEMATIC VARCHAR(255) = ''
AS
    IF @TABLE_SCHEMATIC = ''
        BEGIN
            PRINT 'A variável @TABLE_SCHEMATIC não pode ser nula ou vazia'  
            RETURN  
        END
    
    BEGIN
        DECLARE @DESABILITAR VARCHAR(MAX);

        SELECT @DESABILITAR = STUFF((
            SELECT CONCAT('ALTER TABLE [dbo].[', TEMPSCHEMA.TABLE_NAME, '] NOCHECK CONSTRAINT ALL; ') 
            FROM INFORMATION_SCHEMA.TABLES TEMPSCHEMA WHERE TEMPSCHEMA.TABLE_NAME LIKE CONCAT(@TABLE_SCHEMATIC, '%')
            FOR XML PATH ('')
        ), 1, 0, '')

        EXEC (@DESABILITAR);
    END

    BEGIN
        DECLARE @SCRIPT VARCHAR(MAX);

        SELECT @SCRIPT = STUFF((
            SELECT CONCAT('DELETE FROM [dbo].[', TEMPSCHEMA.TABLE_NAME, ']; DBCC CHECKIDENT (', TEMPSCHEMA.TABLE_NAME, ', RESEED, 0); ') 
            FROM INFORMATION_SCHEMA.TABLES TEMPSCHEMA WHERE TEMPSCHEMA.TABLE_NAME LIKE CONCAT(@TABLE_SCHEMATIC, '%')
            FOR XML PATH ('')
        ), 1, 0, '')
    
        EXEC (@SCRIPT);
    END   

    BEGIN
        DECLARE @HABILITAR VARCHAR(MAX);

        SELECT @HABILITAR = STUFF((
            SELECT CONCAT('ALTER TABLE [dbo].[', TEMPSCHEMA.TABLE_NAME, '] CHECK CONSTRAINT ALL; ') 
            FROM INFORMATION_SCHEMA.TABLES TEMPSCHEMA WHERE TEMPSCHEMA.TABLE_NAME LIKE CONCAT(@TABLE_SCHEMATIC, '%')
            FOR XML PATH ('')
        ), 1, 0, '')

        EXEC (@HABILITAR);
    END      
GO

USE [BASE DE DADOS]
GO

CREATE OR ALTER PROCEDURE [dbo].[DROP_SCHEMA_TABLES] @TABLE_SCHEMATIC VARCHAR(255) = ''
AS
   IF @TABLE_SCHEMATIC = ''
        BEGIN
            PRINT 'A variável @TABLE_SCHEMATIC não pode ser nula ou vazia'  
            RETURN  
        END

    BEGIN
        DECLARE @CONSTRAINTS VARCHAR(max);

        SELECT @CONSTRAINTS = STUFF((
            SELECT CONCAT('ALTER TABLE [dbo].[', CAST(OBJECT_NAME(TEMPSYS.parent_object_id) AS VARCHAR(MAX)), '] DROP CONSTRAINT [', name, ']; ')
            FROM sys.foreign_keys TEMPSYS WHERE OBJECT_NAME(TEMPSYS.parent_object_id) LIKE CONCAT(@TABLE_SCHEMATIC, '%')
            FOR XML PATH ('')
        ), 1, 0, '')

        EXEC (@CONSTRAINTS);

        DECLARE @SCRIPT VARCHAR(MAX);

        SELECT @SCRIPT = STUFF((
            SELECT CONCAT('DROP TABLE [dbo].[', TEMPSCHEMA.TABLE_NAME, ']; ') 
            FROM INFORMATION_SCHEMA.TABLES TEMPSCHEMA WHERE TEMPSCHEMA.TABLE_NAME LIKE CONCAT(@TABLE_SCHEMATIC, '%')
            FOR XML PATH ('')
        ), 1, 0, '')
    
        EXEC (@SCRIPT);
    END
GO