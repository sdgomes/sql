SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_UserRoleDatabase
    @DatabaseName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX)

    SET @SQL = '
    WITH UserRoles AS (
        SELECT 
            dp.name AS Usuario,
            dr.name AS Funcao
        FROM ' + QUOTENAME(@DatabaseName) + '.sys.database_role_members rm
        JOIN ' + QUOTENAME(@DatabaseName) + '.sys.database_principals dp ON rm.member_principal_id = dp.principal_id
        JOIN ' + QUOTENAME(@DatabaseName) + '.sys.database_principals dr ON rm.role_principal_id = dr.principal_id
        WHERE dp.name IN ('''')
    )
    SELECT Usuario, [db_accessadmin], [db_backupoperator], [db_datareader], [db_datawriter], [db_ddladmin], [db_denydatareader], [db_denydatawriter], [db_executor], [db_owner], [db_PCFMasterManager], [db_PCFServices], [db_PCFStdManager], [db_PCFViewer], [db_securityadmin], [DatabaseMailUserRole], [db_ssisadmin], [db_ssisltduser], [db_ssisoperator], [dc_admin], [dc_operator], [dc_proxy], [PolicyAdministratorRole], [ServerGroupAdministratorRole], [ServerGroupReaderRole], [SQLAgentOperatorRole], [SQLAgentReaderRole], [SQLAgentUserRole], [TargetServersRole], [UtilityCMRReader], [UtilityIMRReader], [UtilityIMRWriter]
    FROM (
        SELECT Usuario, Funcao, ''*'' AS TemFuncao
        FROM UserRoles
    ) AS SourceTable
    PIVOT (
        MAX(TemFuncao) FOR Funcao IN ([db_accessadmin], [db_backupoperator], [db_datareader], [db_datawriter], [db_ddladmin], [db_denydatareader], [db_denydatawriter], [db_executor], [db_owner], [db_PCFMasterManager], [db_PCFServices], [db_PCFStdManager], [db_PCFViewer], [db_securityadmin], [DatabaseMailUserRole], [db_ssisadmin], [db_ssisltduser], [db_ssisoperator], [dc_admin], [dc_operator], [dc_proxy], [PolicyAdministratorRole], [ServerGroupAdministratorRole], [ServerGroupReaderRole], [SQLAgentOperatorRole], [SQLAgentReaderRole], [SQLAgentUserRole], [TargetServersRole], [UtilityCMRReader], [UtilityIMRReader], [UtilityIMRWriter])
    ) AS Pivoteado;
    '

    EXEC sp_executesql @SQL

END;
GO

EXEC sp_MS_marksystemobject 'sp_UserRoleDatabase';
GO