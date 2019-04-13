SQL Server Integration Services Monitor Queries
===============================================

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
 
## Release Notes

Available scripts:

* **ssis-execution-status**: Latest executed packages
* **ssis-execution-breakdown**: Execution breakdown for a specific execution
* **ssis-execution-dataflow-info**: Data Flow information for a specific execution
* **ssis-execution-log**: Information/Warning/Error messages found in the log for a specific execution
* **ssis-execution-lookup-cache-usage**: Lookup usage for a specific package/execution
* **ssis-execution-package-history**: Execution historical data 
* **ssis-execution-parameter-values**: Show execution parameter values

## Version History

### v 1.0 

* First release 

### v 1.1

* Improved & fixed the "ssis-execution-log" query
 
### v 1.2

* Added "ssis-execution-parameter-values" query
 
### v 1.3

* Fixed null values in "ssis-execution-dataflow-info" query due to invalid CTE join on Message ID, added "duration_minutes" column alias


