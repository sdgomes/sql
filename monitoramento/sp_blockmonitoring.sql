SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_BlockMonitoring
    @DatabaseName SYSNAME = NULL, -- Filtrar bloqueios por banco de dados (opcional)
    @SessionID INT = NULL         -- Filtrar por sessão específica (opcional)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.blocking_session_id AS [Sessão Bloqueadora],
        b.login_name AS [Usuário Bloqueador],
        r.session_id AS [Sessão Bloqueada],
        s.login_name AS [Usuário Bloqueado],
        r.wait_type AS [Tipo de Espera],
        r.wait_time AS [Tempo de Espera (ms)],
        DB_NAME(r.database_id) AS [Banco de Dados],
        TRY_CAST(qt.text AS NVARCHAR(MAX)) AS [Query Bloqueada]
    FROM sys.dm_exec_requests r
    JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
    LEFT JOIN sys.dm_exec_sessions b ON r.blocking_session_id = b.session_id
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) qt
    WHERE r.blocking_session_id <> 0
        AND (@DatabaseName IS NULL OR DB_NAME(r.database_id) = @DatabaseName) -- Filtro por banco
        AND (@SessionID IS NULL OR r.session_id = @SessionID) -- Filtro por sessão específica
    ORDER BY r.wait_time DESC;
END;
GO

EXEC sp_MS_marksystemobject 'sp_BlockMonitoring';
GO