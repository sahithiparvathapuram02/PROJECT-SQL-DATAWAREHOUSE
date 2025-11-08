/*
STORED PROCEDURE: load BRONZE layer
This stored procedure loads data inTO Bronze schema from .csv files.
It truncates the bronze table before loading data.
Uses 'BULK INSERT' to load data from csv files to bronze tables.
If exists it drops the table.
*/
EXEC BRONZE.LOAD_BRONZE

CREATE OR ALTER PROCEDURE BRONZE.LOAD_BRONZE AS
BEGIN
declare @start_time datetime, @end_time datetime;
begin try
set @start_time=GETDATE();
truncate table bronze.crm_cust_info;
bulk insert bronze.crm_cust_info
from 'C:\DATAWAREHOUSEPROJECT\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
with (
 firstrow=2,
 fieldterminator=',',
 tablock
);
set @end_time=GETDATE();
print'>>lOAD DURATION:' +CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME)AS NVARCHAR);
PRINT'>>-----------------------';
set @start_time=GETDATE();
truncate table bronze.crm_prd_info;
bulk insert bronze.crm_prd_info
from 'C:\DATAWAREHOUSEPROJECT\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
with(
 firstrow=2,
 fieldterminator=',',
 tablock
);
set @end_time=GETDATE();
print'>>lOAD DURATION:' +CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME)AS NVARCHAR);
PRINT'>>-----------------------';
set @start_time=GETDATE();
truncate table bronze.crm_sales_details;
bulk insert bronze.crm_sales_details
from 'C:\DATAWAREHOUSEPROJECT\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
with( 
 firstrow=2,
 fieldterminator=',',
 tablock
);
set @end_time=GETDATE();
print'>>lOAD DURATION:' +CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME)AS NVARCHAR);
PRINT'>>-----------------------';
set @start_time=GETDATE();
truncate table bronze.erp_cust_az12;
bulk insert bronze.erp_cust_az12
from 'C:\DATAWAREHOUSEPROJECT\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
with (
 firstrow=2,
 fieldterminator=',',
 tablock
);
set @end_time=GETDATE();
print'>>lOAD DURATION:' +CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME)AS NVARCHAR);
PRINT'>>-----------------------';
set @start_time=GETDATE();
truncate table bronze.erp_loc_a101;
bulk insert bronze.erp_loc_a101
from 'C:\DATAWAREHOUSEPROJECT\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
with(
 firstrow=2,
 fieldterminator=',',
 tablock
);
set @end_time=GETDATE();
print'>>lOAD DURATION:' +CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME)AS NVARCHAR);
PRINT'>>-----------------------';
set @start_time=GETDATE();
truncate table bronze.erp_px_cat_g1v2;
bulk insert bronze.erp_px_cat_g1v2
from 'C:\DATAWAREHOUSEPROJECT\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
with(
 firstrow=2,
 fieldterminator=',',
 tablock 
);
set @end_time=GETDATE();
print'>>lOAD DURATION:' +CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME)AS NVARCHAR);
PRINT'>>-----------------------'; 
END TRY
BEGIN CATCH
PRINT 'ERROR';
END CATCH
END
