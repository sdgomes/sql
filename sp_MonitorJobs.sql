USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_MonitorJobs]    Script Date: 20/12/2024 14:14:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE sp_MonitorJobs
AS
BEGIN
    SET NOCOUNT ON;

    -- Mostrar status detalhado dos jobs
    SELECT 
        sj.name AS JobName,
        sja.run_requested_date AS StartTime,
		sja.stop_execution_date AS StopTime,
        CASE 
            WHEN sja.start_execution_date IS NOT NULL AND sja.stop_execution_date IS NULL THEN 'Running'
            WHEN sja.stop_execution_date IS NOT NULL THEN 'Completed'
            ELSE 'Not Started'
        END AS JobStatus,
        sja.run_requested_date AS LastRunRequested,
        sja.stop_execution_date AS LastRunCompleted
    FROM msdb.dbo.sysjobs sj
    LEFT JOIN msdb.dbo.sysjobactivity sja
        ON sj.job_id = sja.job_id
    WHERE sja.run_requested_date IS NOT NULL
    ORDER BY sja.run_requested_date DESC;

    PRINT '====================';

    -- Mostrar jobs que estão sendo executados no momento
    SELECT 
        sj.name AS [JobName At Moment],
        ja.start_execution_date AS StartTime,
        r.session_id AS SessionID,
        ja.run_requested_date AS LastRunRequested
    FROM msdb.dbo.sysjobs sj
    INNER JOIN msdb.dbo.sysjobactivity ja
        ON sj.job_id = ja.job_id
    LEFT JOIN sys.dm_exec_requests r
        ON r.command LIKE 'JOB%'
        AND r.status = 'running'
    WHERE ja.stop_execution_date IS NULL
        AND ja.start_execution_date IS NOT NULL;

    PRINT '====================';

    -- Incluir informações de jobs com falhas
    SELECT 
        sj.name AS [JobName As Faild],
		h.run_duration AS Duration,
        h.run_date AS LastRunDate,
        h.run_time AS LastRunTime,
        CASE 
            WHEN h.run_status = 0 THEN 'Failed'
            WHEN h.run_status = 1 THEN 'Succeeded'
            WHEN h.run_status = 2 THEN 'Retry'
            WHEN h.run_status = 3 THEN 'Canceled'
            ELSE 'Unknown'
        END AS LastRunStatus,
        h.message AS LastRunMessage
    FROM msdb.dbo.sysjobs sj
    LEFT JOIN msdb.dbo.sysjobhistory h
        ON sj.job_id = h.job_id
    WHERE h.run_status = 0 -- Apenas falhas
    ORDER BY h.run_date DESC, h.run_time DESC;
END
GO

EXEC sp_MS_marksystemobject 'sp_MonitorJobs';