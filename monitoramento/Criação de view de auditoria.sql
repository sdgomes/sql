USE [master]
GO

CREATE OR ALTER VIEW VW_AUDITORIA_SEGURANCA AS
SELECT 
    event_time,
    server_principal_name AS usuario,
    database_principal_name AS banco,
	schema_name AS schema_afetado,
    object_name AS objeto_afetado,
	session_id,
	statement AS consulta_sql, 
	succeeded AS executado_sucesso,
    CASE action_id
        WHEN 'AUSC' THEN 'ALTER USER - Altera��o de um usu�rio'
        WHEN 'ALDB' THEN 'ALTER DATABASE - Altera��o no banco de dados'
        WHEN 'ALIS' THEN 'ALTER INDEX - Altera��o de �ndices'
        WHEN 'ALLG' THEN 'ALTER LOGIN - Altera��o de logins'
        WHEN 'ALRL' THEN 'ALTER ROLE - Altera��o de uma role'
        WHEN 'ALSC' THEN 'ALTER SCHEMA - Altera��o de um esquema'
        WHEN 'ALTB' THEN 'ALTER TABLE - Altera��o de uma tabela'
        WHEN 'ALTR' THEN 'ALTER TRIGGER - Altera��o de um trigger'
        WHEN 'ALVW' THEN 'ALTER VIEW - Altera��o de uma view'
        WHEN 'APRL' THEN 'APPLICATION ROLE - Uso de role de aplica��o'
        WHEN 'AUDG' THEN 'AUDIT GROUP - Eventos de auditoria'
        WHEN 'AUDS' THEN 'AUDIT SHUTDOWN - Auditoria foi desligada'
        WHEN 'AULI' THEN 'ALTER LOGIN - Modifica��o de login'
        WHEN 'AURM' THEN 'ALTER ROLE MEMBERSHIP - Altera��o de membros de uma role'
        WHEN 'BCKP' THEN 'BACKUP DATABASE - Backup do banco realizado'
        WHEN 'BCKL' THEN 'BACKUP LOG - Backup do log de transa��es'
        WHEN 'CNCB' THEN 'CONNECT DATABASE - Conex�o ao banco'
        WHEN 'CNSV' THEN 'CONNECT SQL - Conex�o ao SQL Server'
        WHEN 'CRDB' THEN 'CREATE DATABASE - Cria��o de banco de dados'
        WHEN 'CRFN' THEN 'CREATE FUNCTION - Cria��o de uma fun��o'
        WHEN 'CRIN' THEN 'CREATE INDEX - Cria��o de um �ndice'
        WHEN 'CRLB' THEN 'CREATE LOGIN - Cria��o de um login'
        WHEN 'CRPR' THEN 'CREATE PROCEDURE - Cria��o de um procedimento'
        WHEN 'CRRL' THEN 'CREATE ROLE - Cria��o de uma role'
        WHEN 'CRSC' THEN 'CREATE SCHEMA - Cria��o de um esquema'
        WHEN 'CRTB' THEN 'CREATE TABLE - Cria��o de uma tabela'
        WHEN 'CRTR' THEN 'CREATE TRIGGER - Cria��o de um trigger'
        WHEN 'CRVW' THEN 'CREATE VIEW - Cria��o de uma view'
        WHEN 'DRDB' THEN 'DROP DATABASE - Exclus�o de banco de dados'
        WHEN 'DRFN' THEN 'DROP FUNCTION - Exclus�o de uma fun��o'
        WHEN 'DRIN' THEN 'DROP INDEX - Exclus�o de um �ndice'
        WHEN 'DRLB' THEN 'DROP LOGIN - Exclus�o de um login'
        WHEN 'DRPR' THEN 'DROP PROCEDURE - Exclus�o de um procedimento'
        WHEN 'DRRL' THEN 'DROP ROLE - Exclus�o de uma role'
        WHEN 'DRSC' THEN 'DROP SCHEMA - Exclus�o de um esquema'
        WHEN 'DRTB' THEN 'DROP TABLE - Exclus�o de uma tabela'
        WHEN 'DRTR' THEN 'DROP TRIGGER - Exclus�o de um trigger'
        WHEN 'DRVW' THEN 'DROP VIEW - Exclus�o de uma view'
        WHEN 'EXLG' THEN 'FAILED LOGIN - Tentativa de login falhou'
        WHEN 'IMPR' THEN 'IMPERSONATE - Usu�rio assumindo identidade de outro'
        WHEN 'LGIS' THEN 'LOGIN SUCCESS - Login bem-sucedido'
        WHEN 'LOBO' THEN 'LOGOUT - Logout do SQL Server'
        WHEN 'RCFN' THEN 'RENAME FUNCTION - Renomea��o de uma fun��o'
        WHEN 'RCIN' THEN 'RENAME INDEX - Renomea��o de um �ndice'
        WHEN 'RCPR' THEN 'RENAME PROCEDURE - Renomea��o de um procedimento'
        WHEN 'RCRL' THEN 'RENAME ROLE - Renomea��o de uma role'
        WHEN 'RCSC' THEN 'RENAME SCHEMA - Renomea��o de um esquema'
        WHEN 'RCTB' THEN 'RENAME TABLE - Renomea��o de uma tabela'
        WHEN 'RCTR' THEN 'RENAME TRIGGER - Renomea��o de um trigger'
        WHEN 'RCVW' THEN 'RENAME VIEW - Renomea��o de uma view'
        WHEN 'REST' THEN 'RESTORE DATABASE - Restaura��o de um banco'
        WHEN 'RSTR' THEN 'RESTORE TRANSACTION LOG - Restaura��o de um log de transa��o'
        WHEN 'RTRP' THEN 'REVERT TRANSACTION - Revers�o de uma transa��o'
        WHEN 'UPDC' THEN 'UPDATE STATISTICS - Atualiza��o de estat�sticas'
        ELSE 'OUTRO - Evento n�o mapeado'
    END AS descricao_evento, 
	additional_information
FROM sys.fn_get_audit_file('D:\MSSQL\AUDIT\LGPD\*.sqlaudit', DEFAULT, DEFAULT);
