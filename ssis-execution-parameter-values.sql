/*
	:: PURPOSE
	Show the parameters values used for a specific execution
	
	:: NOTES
	The first resultset shows the values set via "parameters", the second via the "set" option
	
	:: INFO
	Author:		Davide Mauri
	Version:	1.0

*/
USE SSISDB
GO

/*
	Configuration
*/

-- Filter data by execution id 
DECLARE @executionIdFilter BIGINT = 344247

SELECT * FROM [catalog].[execution_parameter_values] WHERE [execution_id] = @executionIdFilter and [value_set] = 1

SELECT * FROM [catalog].[execution_property_override_values] WHERE [execution_id] = @executionIdFilter
