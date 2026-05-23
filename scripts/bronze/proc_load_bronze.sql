/*
=========================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==========================================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Logs ETL execution steps into the etl_log table.
  - Truncates the bronze tables before loading data.
  - Uses the `COPY` command to load data from csv files to bronze tables.

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
    -Batch identifier associated with the current ETL execution.
    -This stored procedure accepts just one parameter p_batch_id nut does not return any values.

Usage Example:
  CALL bronze.load_bronze(101);
==============================================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze(p_batch_id INT)
LANGUAGE plpgsql
AS $$
BEGIN

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Starting bronze load');
	INSERT INTO etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', '---Loading CRM Tables---');
	
	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Truncating Table: bronze.crm_cust_info');
	TRUNCATE TABLE bronze.crm_cust_info;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Inserting Data into: bronze.crm_cust_info');
	COPY bronze.crm_cust_info
	FROM 'C:/Users/datasets/source_crm/cust_info.csv'
	DELIMITER ','
	CSV HEADER;
	

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Truncating Table: bronze.crm_prd_info');
	TRUNCATE TABLE bronze.crm_prd_info;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Inserting Data into: bronze.crm_prd_info');
	COPY bronze.crm_prd_info
	FROM 'C:/Users//datasets/source_crm/prd_info.csv'
	DELIMITER ','
	CSV HEADER;
	

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Truncating Table: bronze.crm_sales_details');
	TRUNCATE TABLE bronze.crm_sales_details;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', '>> Inserting Data into: bronze.crm_sales_details');
	COPY bronze.crm_sales_details
	FROM 'C:/Users/datasets/source_crm/sales_details.csv'
	DELIMITER ','
	CSV HEADER;


	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', '---Loading ERP tables---');

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Truncating Table: bronze.erp_cust_az12');
	TRUNCATE TABLE bronze.erp_cust_az12;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', '>> Inserting Data into: bronze.erp_cust_az12');
	COPY bronze.erp_cust_az12
	FROM 'C:/Users/datasets/source_erp/cust_az12.csv'
	DELIMITER ','
	CSV HEADER;


	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Truncating Table: bronze.erp_loc_a101');
	TRUNCATE TABLE bronze.erp_loc_a101;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', '>> Inserting Data into: bronze.erp_loc_a101');
	COPY bronze.erp_loc_a101
	FROM 'C:/Users/datasets/source_erp/loc_a101.csv'
	DELIMITER ','
	CSV HEADER;
	

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Truncating Table: bronze.erp_px_cat_g1v2');
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	INSERT INTO public.etl_log (batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', '>> Inserting Data into: bronze.erp_px_cat_g1v2');
	COPY bronze.erp_px_cat_g1v2
	FROM 'C:/Users/datasets/source_erp/px_cat_g1v2.csv'
	DELIMITER ','
	CSV HEADER;

	INSERT INTO public.etl_log(batch_id, layer, procedure_name, log_level, message)
    VALUES (p_batch_id, 'BRONZE', 'load_bronze', 'INFO', 'Bronze load completed');
END
$$


