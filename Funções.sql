USE [programas]
GO

CREATE OR ALTER FUNCTION [dbo].[CONVERT_IMAGE] (@ImageToConvert VARBINARY(MAX))
RETURNS VARCHAR(MAX)
AS 
    BEGIN
        RETURN CONCAT('data:image/webp;base64,', CAST('' AS XML).value('xs:base64Binary(sql:variable("@ImageToConvert"))','VARCHAR(MAX)'))
    END
GO