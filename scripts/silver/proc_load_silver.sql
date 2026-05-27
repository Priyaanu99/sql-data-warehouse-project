/*
=========================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==========================================================================================
Script Purpose:
  This stored procedure performs the ETL(Extract, Transform, Load) process to
  populate data into the 'silver' schema from bronze schema.
  It performs the following actions:
  - Logs ETL execution steps into the etl_log table.
  - Truncates the Silver tables before loading data.
  - Inserts transformed and cleansed data from Bronze into Silver tables.

ETL Logging:
    The etl_log table is used to capture ETL execution activity including:
    - Batch ID
    - ETL layer name
    - Procedure name
    - Log level (INFO / ERROR)
    - Execution messages
    - Execution timestamps

Parameters:
    p_batch_id
    - Batch identifier associated with the current ETL execution.
    - This stored procedure accepts just one parameter p_batch_id and does not return any values.

Usage Example:
  CALL silver.load_silver(201);
==============================================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver(p_batch_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
	--Insertition of data in silver layer tables
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Starting silver load');
	INSERT INTO etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', '---Loading CRM Tables---');
	
	--CRM-CUST-INFO
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Truncating Table: silver.crm_cust_info');
	TRUNCATE TABLE silver.crm_cust_info;
	
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Inserting Data into: silver.crm_cust_info');
	INSERT INTO silver.crm_cust_info(
		   cst_id, 
		   cst_key,
		   cst_firstname,
		   cst_lastname,
		   cst_marital_status,
		   cst_gndr,
		   cst_create_date )  
	SELECT cst_id,
		   cst_key,
		   TRIM(cst_firstname) AS cst_firstname,
		   TRIM(cst_lastname) AS cst_lastname,
		   CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		   		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
				END cst_marital_status,
		   CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		   		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
				END cst_gndr,
			cst_create_date	
	FROM (
		SELECT *,
		ROW_NUMBER() OVER(PARTITION BY cst_id order by cst_create_date DESC) AS flag_last
		FROM bronze.crm_cust_info 
		WHERE cst_id IS NOT NULL
	)t WHERE flag_last = 1;
	
	
	--CRM-PROD-INFO
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Truncating Table: silver.crm_prd_info');
	TRUNCATE TABLE silver.crm_prd_info;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Inserting Data into: silver.crm_prd_info');
	INSERT INTO silver.crm_prd_info(
		  prd_id,
		  cat_id,
		  prd_key,
		  prd_nm,
		  prd_cost,
		  prd_line,
		  prd_start_dt,
		  prd_end_dt)
	SELECT prd_id,
		   REPLACE( SUBSTRING(prd_key, 1, 5), '-', '_') cat_id,
		   SUBSTRING(prd_key, 7, LENGTH(prd_key)) prd_key,
		   prd_nm,
		   COALESCE(prd_cost, 0 ) prd_cost,
		   CASE UPPER(TRIM(prd_line))
		   		WHEN 'R' THEN 'Road'
		   		WHEN 'M' THEN 'Mountain'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
				END AS prd_line,
		   prd_start_dt,
		   (LEAD(prd_start_dt, 1) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1) AS prd_end_dt
	FROM bronze.crm_prd_info;

	
	--CRM-SALES-DETAILS
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Truncating Table: silver.crm_sales_details');
	TRUNCATE TABLE silver.crm_sales_details;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Inserting Data into: silver.crm_sales_details');
	INSERT INTO silver.crm_sales_details(
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
	SELECT sls_ord_num,
		   sls_prd_key,
		   sls_cust_id,
		   CASE WHEN (sls_order_dt) <= 0 OR LENGTH( CAST(sls_order_dt AS TEXT)) != 8 THEN NULL
		   ELSE CAST(CAST(sls_order_dt AS TEXT) AS DATE)
		   END sls_order_dt,
		   CASE WHEN sls_ship_dt <= 0 OR LENGTH( CAST(sls_ship_dt AS TEXT)) != 8 THEN NULL 
		   ELSE CAST(CAST(sls_ship_dt AS TEXT) AS DATE)
		   END sls_ship_dt,
		   CASE WHEN sls_due_dt <= 0 OR LENGTH( CAST(sls_due_dt AS TEXT)) != 8 THEN NULL
		   ELSE CAST(CAST(sls_due_dt AS TEXT) AS DATE)
		   END sls_due_dt,
		   CASE WHEN sls_sales <= 0 OR sls_sales IS NULL 
		   		OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price) 
				ELSE sls_sales
				END sls_sales,
		   sls_quantity,
		   CASE WHEN sls_price <= 0 OR sls_price IS NULL
		   THEN sls_sales / NULLIF(ABS(sls_quantity), 0)
		   ELSE sls_price
		   END sls_price
	FROM bronze.crm_sales_details;
	
	
	--ERP CUST AZ12
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Truncating Table: silver.erp_cust_az12');
	TRUNCATE TABLE silver.erp_cust_az12;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Inserting Data into: silver.erp_cust_az12');
	INSERT INTO silver.erp_cust_az12(
		   cid,
		   bdate,
		   gen
	)
	SELECT CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
		   ELSE cid
		   END cid, 
		   CASE WHEN bdate > CURRENT_DATE THEN NULL
		   ELSE bdate
		   END bdate,
		   CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		   WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		   ELSE 'n/a'
		   END gen
	FROM bronze.erp_cust_az12;
	
	
	--ERP LOC A101
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Truncating Table: silver.erp_loc_a101');
	TRUNCATE TABLE silver.erp_loc_a101;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Inserting Data into: silver.erp_loc_a101');
	INSERT INTO silver.erp_loc_a101(
		 cid,
		 cntry
	)
	SELECT REPLACE(cid, '-', '') AS cid,
		   CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		   WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		   WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		   ELSE TRIM(cntry)
		   END cntry
	FROM bronze.erp_loc_a101;
	
	
	--ERP PX CAT G1V2
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Truncating Table: silver.erp_px_cat_g1v2');
	TRUNCATE TABLE silver.erp_px_cat_g1v2;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Inserting Data into: silver.erp_px_cat_g1v2');
	INSERT INTO silver.erp_px_cat_g1v2(
		   id,
		   cat,
		   subcat,
		   maintenance
	) 
	SELECT id,
		   cat,
		   subcat,
		   maintenance
	FROM bronze.erp_px_cat_g1v2;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'SILVER', 'load_silver', 'INFO', 'Silver load completed');

	--EXCEPTION BLOCK
	EXCEPTION
    WHEN OTHERS THEN
	
        INSERT INTO public.etl_log(
            batch_id,
            layer,
            procedure_name,
            log_level,
            message
        )
        VALUES (
            p_batch_id,
            'SILVER',
            'load_silver',
            'ERROR',
            SQLERRM
        );
		RAISE NOTICE 'Error Occured while loading silver layer';
END
$$
