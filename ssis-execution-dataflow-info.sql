/*
	:: PURPOSE
	Show the Data Flow information of a specific Execution
	
	:: NOTES
	The first resultset shows the packages and the second one shows the 
	dataflows found in the packages, along with loaded number of rows
	set to the destination
	
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



/*
	Implementation
*/

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
	b.event_message_id,
	b.package_path,
	b.message_source_name,
	pre_message_time = b.message_time,
	post_message_time = e.message_time,
	DATEDIFF(mi, b.message_time, e.message_time)
FROM
	ctePRE b
LEFT OUTER JOIN
	ctePOST e ON b.operation_id = e.operation_id AND b.package_name = e.package_name AND b.message_source_id = e.message_source_id AND b.event_message_id=e.event_message_id
WHERE
	b.operation_id = @executionIdFilter
AND
	b.package_path = '\Package'
ORDER BY
	b.event_message_id desc
;

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
	event_message_id,
	package_name,
	message_source_name,
	message_time,
	destination_name = SUBSTRING([message], token_destination_name_start,  token_destination_name_end - token_destination_name_start),
	loaded_rows = SUBSTRING([message], token_rows_start, token_rows_end - token_rows_start),
	[message]
FROM 
	cte as c 
WHERE
	c.operation_id = @executionIdFilter
AND 
	subcomponent_name = 'SSIS.Pipeline' 
AND 
	[message] like '%rows.%'
ORDER BY 
	event_message_id DESC
