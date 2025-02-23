SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_UserRoleServer
AS
BEGIN
    SET NOCOUNT ON;

    WITH UserRoles AS (
        SELECT 
            sp.name AS Usuario,
            spr.name AS Funcao
        FROM sys.server_role_members rm
        JOIN sys.server_principals sp ON rm.member_principal_id = sp.principal_id
        JOIN sys.server_principals spr ON rm.role_principal_id = spr.principal_id
        WHERE sp.name IN ('') 
    )
    SELECT Usuario, [bulkadmin], [dbcreator], [diskadmin], [processadmin], [securityadmin], [serveradmin], [setupadmin], [sysadmin]
    FROM (
        SELECT Usuario, Funcao, '*' AS TemFuncao
        FROM UserRoles
    ) AS SourceTable
    PIVOT (
        MAX(TemFuncao) FOR Funcao IN ([bulkadmin], [dbcreator], [diskadmin], [processadmin], [securityadmin], [serveradmin], [setupadmin], [sysadmin])
    ) AS Pivoteado;
END;
GO

EXEC sp_MS_marksystemobject 'sp_UserRoleServer';
GO