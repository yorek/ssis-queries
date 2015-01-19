/*
	:: PURPOSE
	Show the execution breakdown for a specific execution (operation_id)
	
	:: NOTES
	None
	
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
DECLARE @operation_id AS bigint = 1234;



/*
	Implementation
*/

WITH 
ctePRE AS 
(
	SELECT * FROM catalog.event_messages em  
	WHERE em.event_name IN ('OnPreExecute') and operation_id = @operation_id
	
), 
ctePOST AS 
(
	SELECT * FROM catalog.event_messages em 
	WHERE em.event_name IN ('OnPostExecute') and operation_id = @operation_id
)
SELECT
	b.operation_id,
	e2.status,
	status_desc = CASE e2.status 
						WHEN 1 THEN 'Created'
						WHEN 2 THEN 'Running'
						WHEN 3 THEN 'Cancelled'
						WHEN 4 THEN 'Failed'
						WHEN 5 THEN 'Pending'
						WHEN 6 THEN 'Ended Unexpectedly'
						WHEN 7 THEN 'Succeeded'
						WHEN 8 THEN 'Stopping'
						WHEN 9 THEN 'Completed'
					END,
	b.event_message_id,
	--b.package_path,
	b.execution_path,
	b.message_source_name,
	pre_message_time = b.message_time,
	post_message_time = e.message_time,
	DATEDIFF(mi, b.message_time, COALESCE(e.message_time, SYSDATETIMEOFFSET()))
FROM
	ctePRE b
LEFT OUTER JOIN
	ctePOST e ON b.operation_id = e.operation_id AND b.package_name = e.package_name AND b.message_source_id = e.message_source_id and b.execution_path = e.execution_path
INNER JOIN
	[catalog].executions e2 ON b.operation_id = e2.execution_id
WHERE
	b.package_path = '\Package'
AND
--	b.message_source_name = @source_name
	b.operation_id = @operation_id
ORDER BY
	b.event_message_id desc
;