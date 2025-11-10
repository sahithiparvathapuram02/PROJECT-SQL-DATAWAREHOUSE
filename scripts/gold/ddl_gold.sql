/*
It creates views for the gold layer n data warehouse
The gold layer represents the final dimension and fact tables
usage-
These views can be queried directly for analytics and reporting.
*/
IF OBJECT_ID('gold.dim_customers', 'V') is not null
   drop view gold.dim_customers;
GO
CREATE view gold.dim_customers as
SELECT 
ROW_NUMBER() over(order by cst_id) as customer_key,
ci.cst_id AS customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name ,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_martial_status as marital_status,
CASE
 WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
 ELSE COALESCE(ca.gen, 'n/a')
END AS gender, 
ca.bdate as birthdate,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on  ci.cst_key=la.cid;
IF OBJECT_ID('gold.dim_products', 'V') is not null
   drop view gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
FROM silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null;
IF OBJECT_ID('gold.fact_sales', 'V') is not null
   drop view gold.fact_sales;
GO
create view gold.fact_sales as
select 
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
FROM silver.crm_sales_details sd
left join gold.dim_products pr
on sd.sls_prd_key=pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id;

