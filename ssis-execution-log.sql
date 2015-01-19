/*
	:: PURPOSE
	Show the Information/Warning/Error messages found in the log for a specific execution
	
	:: NOTES
	The first resultset is the log, the second one shows the performance
	
	:: INFO
	Author:		Davide Mauri
	Version:	1.0

*/
USE SSISDB
GO

/*
	Configuration
*/

-- Filter data by execution id (use NULL for no filter)
DECLARE @executionIdFilter BIGINT = 20143;

-- Show Only Child Packages or everyhing
DECLARE @showOnlyChildPackages BIT = 1;



/*
	Implementation
*/

/*
	Log Info
*/
SELECT * FROM catalog.event_messages em 
WHERE em.operation_id = @executionIdFilter 
AND em.event_name IN ('OnInformation', 'OnError', 'OnWarning')
AND package_path LIKE CASE WHEN @showOnlyChildPackages = 1 THEN '\Package' ELSE '%' END
ORDER BY em.event_message_id;


/*
	Performance Breakdown
*/
IF (OBJECT_ID('tempdb..#t') IS NOT NULL) DROP TABLE #t;

WITH 
ctePRE AS 
(
	SELECT * FROM catalog.event_messages em 
	WHERE em.event_name IN ('OnPreExecute')
	AND em.operation_id = @executionIdFilter 
	
), 
ctePOST AS 
(
	SELECT * FROM catalog.event_messages em 
	WHERE em.event_name IN ('OnPostExecute')
	AND em.operation_id = @executionIdFilter 
)
SELECT
	b.operation_id,
	from_event_message_id = b.event_message_id,
	to_event_message_id = e.event_message_id,
	b.package_path,
	b.message_source_name,
	pre_message_time = b.message_time,
	post_message_time = e.message_time,
	elapsed_time_min = DATEDIFF(mi, b.message_time, COALESCE(e.message_time, SYSDATETIMEOFFSET()))
INTO
	#t
FROM
	ctePRE b
LEFT OUTER JOIN
	ctePOST e ON b.operation_id = e.operation_id AND b.package_name = e.package_name AND b.message_source_id = e.message_source_id AND b.[execution_path] = e.[execution_path]
INNER JOIN
	[catalog].executions e2 ON b.operation_id = e2.execution_id
WHERE
	e2.status IN (2,7)
;

SELECT * FROM #t 
WHERE package_path LIKE CASE WHEN @showOnlyChildPackages = 1 THEN '\Package' ELSE '%' END
ORDER BY  #t.pre_message_time DESC
