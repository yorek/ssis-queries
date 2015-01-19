/*
	:: PURPOSE
	Show lookup usage for a specific package/execution
	
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
DECLARE @executionIdFilter BIGINT = 20143

-- Filter data by package name (use % for no filter)
DECLARE @packageNamePattern NVARCHAR(100) = '%%'



/*
	Implementation
*/
;WITH cte AS
(
	SELECT 
		em.[operation_id],
		em.[message],
		em.[package_name],
		em.[package_path],
		em.[execution_path],
		
		lookup_token_start = CHARINDEX(': The ', em.[message]) + 6,
		lookup_token_end = CHARINDEX('processed', em.[message]),

		cached_rows_token_start = CHARINDEX('processed', em.[message]) + 9,
		cached_rows_token_end = CHARINDEX('rows in the cache.', em.[message]),

		process_time_token_start = CHARINDEX('time was ', em.[message]) + 9,
		process_time_token_end = CHARINDEX('seconds.', em.[message]),	

		cached_bytes_token_start = CHARINDEX('cache used ', em.[message]) + 11,
		cached_bytes_token_end = CHARINDEX('bytes of ', em.[message])
		
	FROM 
		[SSISDB].[catalog].[event_messages] em
	WHERE 
		em.[event_name] = 'OnInformation'
	AND
		em.[package_name] like @packageNamePattern
	AND	
		em.[operation_id] = ISNULL(@executionIdFilter, em.[operation_id])
	AND
		em.[message] LIKE '%The cache used %'
)
SELECT	
	em.[operation_id],
	em.[message],
	em.[package_name],
	em.[package_path],
	em.[execution_path],		
	[lookup] = SUBSTRING(em.[message], lookup_token_start, lookup_token_end - lookup_token_start)
	,cached_rows = SUBSTRING(em.[message], cached_rows_token_start , cached_rows_token_end - cached_rows_token_start)
	,process_time_secs = SUBSTRING(em.[message], process_time_token_start, process_time_token_end - process_time_token_start)
	,cached_bytes = SUBSTRING(em.[message], cached_bytes_token_start, cached_bytes_token_end - cached_bytes_token_start)
FROM
	cte em
OPTION
	(RECOMPILE)