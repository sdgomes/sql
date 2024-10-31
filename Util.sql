--region PROCEDURE
CREATE OR ALTER PROCEDURE [dbo].[JSON_CONTATOS_OUTLOOK]
	@JSON BIT = 1
AS
    IF @JSON = 1
        BEGIN
            SELECT 
                'Induscabos' AS organization,
                'https://induscabos.com.br' AS website,
                dbo.CAPITALIZE_STRING(SUBSTRING(AU.NOME, 1, CHARINDEX(' ', AU.NOME) - 1)) AS firstName,
                dbo.CAPITALIZE_STRING(REVERSE(SUBSTRING(REVERSE(AU.NOME), 1, CHARINDEX(' ', REVERSE(AU.NOME)) - 1))) AS lastName,     
                CONCAT('+55 (11) 4634-9000 x ', RC.RAMAL) AS phone,
                CASE
                    WHEN RC.EMAIL IS NULL THEN AU.EMAIL
                    ELSE RC.EMAIL
                END AS email
            FROM RAM_CONTATO RC
                LEFT JOIN ACS_USUARIO AU ON AU.ID_USUARIO = RC.ID_USUARIO
                    AND AU.D_E_L_E_T_ <> '*'
                LEFT JOIN ACS_LOGIN AL ON AL.ID_LOGIN = AU.ID_LOGIN	
                    AND AL.D_E_L_E_T_ <> '*'
                LEFT JOIN P5DADOS_HOM.dbo.SQB010 SQB ON SQB.QB_CC = RC.CENTRO_CUSTO
                    AND SQB.D_E_L_E_T_ <> '*'
            WHERE RC.D_E_L_E_T_ <> '*' AND AU.NOME IS NOT NULL AND AU.EMAIL <> '' 
            ORDER BY AU.NOME ASC
            FOR JSON PATH
        END
    ELSE
        BEGIN
            SELECT 
                'Induscabos' AS organization,
                'https://induscabos.com.br' AS website,
                dbo.CAPITALIZE_STRING(SUBSTRING(AU.NOME, 1, CHARINDEX(' ', AU.NOME) - 1)) AS firstName,
                dbo.CAPITALIZE_STRING(REVERSE(SUBSTRING(REVERSE(AU.NOME), 1, CHARINDEX(' ', REVERSE(AU.NOME)) - 1))) AS lastName,     
                CONCAT('+55 (11) 4634-9000 x ', RC.RAMAL) AS phone,
                CASE
                    WHEN RC.EMAIL IS NULL THEN AU.EMAIL
                    ELSE RC.EMAIL
                END AS email
            FROM RAM_CONTATO RC
                LEFT JOIN ACS_USUARIO AU ON AU.ID_USUARIO = RC.ID_USUARIO
                    AND AU.D_E_L_E_T_ <> '*'
                LEFT JOIN ACS_LOGIN AL ON AL.ID_LOGIN = AU.ID_LOGIN	
                    AND AL.D_E_L_E_T_ <> '*'
                LEFT JOIN P5DADOS_HOM.dbo.SQB010 SQB ON SQB.QB_CC = RC.CENTRO_CUSTO
                    AND SQB.D_E_L_E_T_ <> '*'
            WHERE RC.D_E_L_E_T_ <> '*' AND AU.NOME IS NOT NULL AND AU.EMAIL <> '' 
            ORDER BY AU.NOME ASC
        END
GO
-- ** PROCEDURE ** --
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
-- ** PROCEDURE ** --
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
-- ** PROCEDURE ** --
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
--endregion

--region VIEWS
CREATE OR ALTER VIEW UTL_DEPARTAMENTOS AS
SELECT	
	QB_DEPTO AS ID_DEPARTAMENTO, 
	QB_DESCRIC AS DEPARTAMENTO, 
	QB_CC AS CENTRO_CUSTO, 
	QB_GESTOR AS GESTOR, 
	D_E_L_E_T_
FROM P5DADOS_HOM.dbo.SQB010 WHERE D_E_L_E_T_ <> '*' 
GO
--endregion

--region FUNCTION
CREATE OR ALTER FUNCTION [dbo].[CONVERT_IMAGE] (@ImageToConvert VARBINARY(MAX))
RETURNS VARCHAR(MAX)
AS 
    BEGIN
        RETURN CONCAT('data:image/webp;base64,', CAST('' AS XML).value('xs:base64Binary(sql:variable("@ImageToConvert"))','VARCHAR(MAX)'))
    END
GO
-- ** FUNCTION ** --
CREATE OR ALTER FUNCTION [dbo].[CAPITALIZE_STRING] (@inputString NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @inputString IS NULL
    BEGIN
        RETURN NULL
    END

    DECLARE @outputString NVARCHAR(MAX) = ''
    DECLARE @currentChar NCHAR(1)
    DECLARE @i INT = 1
    DECLARE @isNewWord BIT = 1 

    WHILE @i <= LEN(@inputString)
    BEGIN
        SET @currentChar = SUBSTRING(@inputString, @i, 1)

        IF @currentChar = ' '
        BEGIN
            SET @isNewWord = 1
            SET @outputString = @outputString + @currentChar
        END
        ELSE
        BEGIN
            IF @isNewWord = 1
            BEGIN
                SET @outputString = @outputString + UPPER(@currentChar)
                SET @isNewWord = 0
            END
            ELSE
            BEGIN
                SET @outputString = @outputString + LOWER(@currentChar)
            END
        END

        SET @i = @i + 1
    END

    RETURN @outputString
END
GO
-- ** FUNCTION ** --
CREATE OR ALTER FUNCTION [dbo].[SPLIT_STRING] (
   @String NVARCHAR(MAX), 
   @Delimiter CHAR(1)
)
RETURNS @Results TABLE (ID INT)
AS
BEGIN
    SET @String = REPLACE(REPLACE(@String, '(', ''), ')', '')

    DECLARE @Index INT
    DECLARE @Value NVARCHAR(MAX)
    SET @Index = CHARINDEX(@Delimiter, @String)
    
    WHILE @Index > 0
    BEGIN
        SET @Value = LEFT(@String, @Index - 1)
        INSERT INTO @Results (ID) VALUES (CAST(@Value AS INT))
        SET @String = RIGHT(@String, LEN(@String) - @Index)
        SET @Index = CHARINDEX(@Delimiter, @String)
    END

    IF LEN(@String) > 0
        INSERT INTO @Results (ID) VALUES (CAST(@String AS INT))
    
    RETURN
END
--endregion