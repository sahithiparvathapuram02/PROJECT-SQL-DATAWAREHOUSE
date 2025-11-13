/*
This stored procedure performs ETL-Extract, Transform and Load functions to populatesilver schemas tables bronze schemas.
Trunates silver tables
Inserts transformed and cleaned data from bronze to silver layer
USAGE EXAMPLE:
EXEC silver.load_silver
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
 DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
 BEGIN TRY
    SET @batch_start_time=GETDATE();
    PRINT 'LOADING SILVER LAYER';
    PRINT 'LOADING CRM TABLES';
    --loading silver.crm_cust_info
    SET @start_time=GETDATE();
    PRINT '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    PRINT '>> Inserting data into : silver.crm_cust_info';
    INSERT INTO Silver.crm_cust_info(
         cst_id,
         cst_key,
         cst_firstname,
         cst_lastname,
         cst_gndr,
         cst_martial_status,
         cst_create_date)
    SELECT 
    cst_id,
    cst_key,
    trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as cst_lastname,
    case 
      when upper(trim(cst_gndr)) ='F' Then 'FEMALE'
      when upper(trim(cst_gndr)) ='M' Then 'MALE'
      else 'N/A'
    end cst_gndr,
    case 
      when upper(trim(cst_martial_status)) ='S' Then 'SINGLE'
      when upper(trim(cst_martial_status))='M' Then 'MARRIED'
      else 'N/A'
    end cst_martial_status,
    cst_create_date
    from(
    select *,
    ROW_NUMBER() over(partition BY CST_id order bY CST_CREATE_date desc) as flag_last
    from Bronze.CRM_cust_inFO
    where cst_id is not null)t 
    where flag_last=1; 
    SET @end_time=GETDATE();
    PRINT'>>Load duration:'+CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR)+'SECONDS';
    PRINT '>> Truncating Table: silver.crm_prd_info';
    --loading silver.crm_prd_info
    SET @start_time=GETDATE();
    TRUNCATE TABLE silver.crm_prd_info;
    PRINT '>> Inserting data into : silver.prd_cust_info';
    INSERT INTO Silver.crm_prd_info(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
    )
    Select 
    prd_id,
    REPLACE(SUBSTRING(prd_key,1, 5), '-','_')as cat_id,
    SUBSTRING(prd_key, 7, len(prd_key)) as prd_key,
    prd_nm,
    ISNULL(prd_cost,0) as prd_cost,
    CASE
     WHEN UPPER(TRIM(prd_line))='M' THEN 'MOUNTAIN'
     WHEN UPPER(TRIM(prd_line))='R' THEN 'ROAD'
     WHEN UPPER(TRIM(prd_line))='S' THEN 'OTHER SALES'
     WHEN UPPER(TRIM(prd_line))='T' THEN 'TOURING'
     ELSE 'N/A'
    END AS prd_line,
    CAST(prd_start_dt as DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as DATE) as prd_end_dt 
    from bronze.crm_prd_info;
    SET @end_time=GETDATE();
    PRINT'>>Load duration:'+CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR)+'SECONDS';
    --Loading Silver.crm_sales_details
    SET @start_time=GETDATE();
    PRINT '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    PRINT '>> Inserting data into : silver.crm_sales_details'; 
    INSERT INTO Silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
    )
    Select
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
     WHEN sls_order_dt=0 OR LEN(sls_order_dt)!=8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END as sls_order_dt,
    CASE 
     WHEN sls_ship_dt=0 OR LEN(sls_ship_dt)!=8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END as sls_ship_dt,
    CASE 
     WHEN sls_due_dt=0 OR LEN(sls_due_dt)!=8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END as sls_due_dt,
    CASE 
     WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity *ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE 
     WHEN sls_price is NULL OR sls_price<=0
     THEN sls_sales/NULLIF(sls_quantity, 0)
     ELSE sls_price
    END AS sls_price
    from bronze.crm_sales_details; 
    SET @end_time=GETDATE();
    PRINT'>>Load duration:'+CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR)+'SECONDS';
    --loading silver.erp_cust_az12
    SET @start_time=GETDATE()
    PRINT '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    PRINT '>> Inserting data into : silver.erp_cust_az12'; 
    INSERT INTO Silver.erp_cust_az12(
    cid,
    bdate,
    gen
    )
    SELECT 
    CASE
     WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
     ELSE cid
    END cid,
    CASE 
     WHEN bdate>getdate() then null
     ELSE bdate
    END AS bdate,
    CASE 
     WHEN UPPER(TRIM(gen)) in('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) in ('M', 'MALE') THEN 'Male'
     ELSE 'n/a'
    END AS gen 
    from bronze.erp_cust_az12;
    SET @end_time=GETDATE();
    PRINT'>>Load duration:'+CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR)+'SECONDS';
    --Loading silver.erp_loc_a101
    SET @start_time=GETDATE();
    PRINT '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    PRINT '>> Inserting data into : silver.erp_loc_a101';
    INSERT INTO Silver.erp_loc_a101(
    cid,
    cntry
    )
    select 
    replace(cid,'-','') cid,
    CASE 
     WHEN TRIM(cntry)= 'DE' THEN 'Germany'
     WHEN TRIM(cntry) in('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) ='' or cntry is null THEN 'n/a'
     ELSE TRIM(cntry)
    END AS cntry
    from bronze.erp_loc_a101;
    SET @end_time=GETDATE();
    PRINT'>>Load duration:'+CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR)+'SECONDS';
    --loading silver.erp_px_cat_g1v2
    SET @start_time=GETDATE();
    PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    PRINT '>> Inserting data into : silver.erp_px_cat_g1v2';
    INSERT INTO Silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance)
    select 
    id,
    cat,
    subcat,
    maintenance
    from bronze.erp_px_cat_g1v2;
    SET @end_time=GETDATE();
    PRINT'>>Load duration:'+CAST(DATEDIFF(SECOND, @start_time,@end_time) as NVARCHAR)+'SECONDS';

    SET @batch_end_time=GETDATE();
    PRINT 'Loading silver layer is completed';
    PRINT ' -Total load duration :'+ CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)+'SECONDS';
 END  TRY
 BEGIN  CATCH
    PRINT ' ERROR MESSAGE'+ ERROR_MESSAGE();
    PRINT 'ERROR MESSAGE'+ CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT 'ERROR MESSAGE'+ CAST(ERROR_STATE() AS NVARCHAR);
 END CATCH
END;
