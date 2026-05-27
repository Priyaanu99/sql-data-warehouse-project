/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- =======================================================================
-- Checking 'silver.crm_cust_info'
-- =======================================================================
-- Check for NULLS or Duplicates in Primary Key
-- Expectations: No Results
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 
    OR cst_id IS NULL;

-- Check if there's Unwanted spaces in the first and last name columns
-- Expectations: No Results
SELECT cst_firstname, length(cst_firstname), 
	   cst_lastname, length(cst_lastname)
FROM silver.crm_cust_info;
--OR 
SELECT cst_firstname,
	     cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) 
   OR cst_lastname != TRIM(cst_lastname);

-- Check if there's Unwanted spaces in the marital status column
-- Expectations: No Results
SELECT cst_marital_status
from silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- DATA Standardization & Consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- Check if there's Unwanted spaces in the gender column
-- Expectations: No Results
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- DATA Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- =======================================================================
-- Checking 'silver.crm_prd_info'
-- =======================================================================
-- Check for NULL and Duplicates in Primary Key 
-- Expectations: No Results
SELECT prd_id, count(*)
FROM silver.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*) > 1 
    OR prd_id IS NULL;

-- Check for Unwanted Spaces in prd_key column
-- Expectations: No Results
SELECT prd_key 
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key);

-- Check for Unwanted Spaces in prd_nm column
-- Expectations: No Results
SELECT * 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULL or negative cost value
-- Expectations: No Results
SELECT * 
FROM silver.crm_prd_info
WHERE prd_cost < 0 
   OR prd_cost IS NULL;

-- Check for Unwanted Spaces in prd_line column
-- Expectations: No Results
SELECT * 
FROM silver.crm_prd_info
WHERE prd_line != TRIM(prd_line);

-- DATA Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check if prd_start_dt is > prd_end_dt and if start_date IS NULL
-- Expectations: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt 
   OR prd_start_dt IS NULL;

-- =======================================================================
-- Checking 'silver.crm_sales_details'
-- =======================================================================
-- Check if sls_ord_num IS NULL or has Unwanted Spaces
-- Expectations: No Results
SELECT sls_ord_num 
FROM silver.crm_sales_details 
WHERE sls_ord_num IS NULL 
	 OR sls_ord_num != TRIM(sls_ord_num);

-- Expectations: No Results
SELECT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL 
	 OR sls_prd_key != TRIM(sls_prd_key)
	 OR sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- Expectations: No Results
SELECT sls_cust_id
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL OR sls_cust_id = 0
	 OR sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT sls_sales,
	     sls_quantity,
	     sls_price
FROM silver.crm_sales_details
WHERE sls_sales <= 0 OR sls_sales IS NULL 
	 OR sls_quantity <= 0sls_quantity IS NULL 
	 OR sls_price <= 0 OR sls_price IS NULL 
	 OR sls_sales != sls_quantity * sls_price
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Check for NULL and Duplicates in Primary Key 
-- Expectations: No Results
SELECT cid, COUNT(*) 
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;

-- Check if there's Unwanted spaces 
-- Expectations: No Results
SELECT cid 
FROM silver.erp_cust_az12
WHERE cid IS NULL OR cid != TRIM(cid);

-- Check if cid different from cst_key in cust_info
-- Expectations: No Results
SELECT *
FROM silver.erp_cust_az12 
WHERE SUBSTRING(cid, 4) NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > CURRENT_DATE;

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces and NULL values in Primary Key
-- Expectation: No Results
SELECT id 
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL 
   OR id != TRIM(id);

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT cat 
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT subcat 
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT maintenance 
FROM silver.erp_px_cat_g1v2;








