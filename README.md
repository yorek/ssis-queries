SQL Server Integration Services Monitor Queries
=======================================

The purpose of this project is to provide a set of queries to easily extract data from SSISDB database, in order to get quick insight on:

* Running packages, 
* Performance History
* Run outcome
* DataFlow statistics and performances
* Lookup component memory usage
* Lookup component duplicate warnings
* Errors
* Memory Warnings

The provided queries are also used in the [ssis-dashboard](https://github.com/yorek/ssis-dashboard) project.
 
##Release Notes

Available scripts:

*ssis-execution-status*
Show the latest executed packages

*ssis-execution-breakdown*
Show the execution breakdown for a specific execution

*ssis-execution-dataflow-info*
Show the Data Flow information of a specific execution

*ssis-execution-log*
Show the Information/Warning/Error messages found in the log for a specific execution

*ssis-execution-lookup-cache-usage*
Show lookup usage for a specific package/execution

*ssis-execution-package-history*
Show execution historical data 

##Version History

###v 1.0 

* First release 
