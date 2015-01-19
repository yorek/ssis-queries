/*
	:: PURPOSE
	Show execution historical data 
	
	:: NOTES
	Also show Dataflow destination informations
	
	:: INFO
	Author:		Davide Mauri
	Version:	1.0

*/
USE SSISDB
GO

/*
	Configuration
*/

-- Filter data by message source name (use % for no filter)
DECLARE @sourceNameFilter AS nvarchar(max) = '%%';



/*
	Implementation
*/
IF (OBJECT_ID('tempdb..#t') IS NOT NULL) DROP TABLE #t;

WITH 
ctePRE AS 
(
	SELECT * FROM catalog.event_messages em 
	WHERE em.event_name IN ('OnPreExecute')
	
), 
ctePOST AS 
(
	SELECT * FROM catalog.event_messages em 
	WHERE em.event_name IN ('OnPostExecute')
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
	ctePOST e ON b.operation_id = e.operation_id AND b.package_name = e.package_name AND b.message_source_id = e.message_source_id
INNER JOIN
	[catalog].executions e2 ON b.operation_id = e2.execution_id
WHERE
	b.package_path = '\Package'
AND
	b.message_source_name LIKE @sourceNameFilter
AND
	e2.status IN (2,7)
;
SELECT * FROM #t ORDER BY operation_id DESC;

-- Show DataFlow Destination Informations
WITH cte AS
(
	SELECT
		*,
		token_destination_name_start = CHARINDEX(': "', [message]) + 3,
		token_destination_name_end = CHARINDEX('" wrote', [message]),
		token_rows_start = LEN([message]) - CHARINDEX('e', REVERSE([message]), 1) + 3,
		token_rows_end = LEN([message]) - CHARINDEX('r', REVERSE([message]), 1)
	FROM
		[catalog].[event_messages] em
)
SELECT TOP 100
	c.operation_id,
	event_message_id,
	package_name,
	c.message_source_name,
	message_time,
	--destination_name = SUBSTRING([message], token_destination_name_start,  token_destination_name_end - token_destination_name_start),
	loaded_rows = SUBSTRING([message], token_rows_start, token_rows_end - token_rows_start),
	[message]
FROM 
	cte as c 
INNER JOIN
	#t t ON c.operation_id = t.operation_id AND c.event_message_id BETWEEN t.from_event_message_id AND t.to_event_message_id
WHERE
	subcomponent_name = 'SSIS.Pipeline' 
AND 
	[message] like '%rows.%'
ORDER BY 
	c.operation_id desc, message_time DESC