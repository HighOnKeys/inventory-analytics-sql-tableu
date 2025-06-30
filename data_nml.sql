
-- database normalization

-- Useful for joins and lookups

CREATE INDEX idx_product_id ON inventory_transactions(product_id);
CREATE INDEX idx_store_id ON inventory_transactions(store_id);

-- Speed up time-based queries
CREATE INDEX idx_date ON inventory_transactions(date);

-- Speed up filters on stockouts or sales
CREATE INDEX idx_demand_vs_inventory ON inventory_transactions(demand_forecast, inventory_level);

--  Window Functions Example
WITH monthly_sales AS (
    SELECT 
        store_id, 
        product_id, 
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(units_sold) AS monthly_units_sold
    FROM inventory_transactions
    GROUP BY store_id, product_id, DATE_FORMAT(date, '%Y-%m-01')
)
SELECT 
    store_id,
    product_id,
    sales_month,
    monthly_units_sold,
    RANK() OVER (
        PARTITION BY store_id, sales_month
        ORDER BY monthly_units_sold DESC
    ) AS rank_in_store_month
FROM monthly_sales
ORDER BY store_id, sales_month, rank_in_store_month;

-- analytical outputs

-- 1. Identify Fast-Selling vs. Slow-Moving Products
 
SELECT 
    product_id,
    SUM(units_sold) AS total_sales
FROM inventory_transactions
GROUP BY product_id
ORDER BY total_sales DESC;

-- 2. Recommend Stock Adjustments to Reduce Holding Cost
SELECT 
    product_id,
    COUNT(*) AS days_tracked,
    SUM(CASE WHEN inventory_level > demand_forecast * 1.5 THEN 1 ELSE 0 END) AS overstock_days,
    SUM(CASE WHEN inventory_level < demand_forecast * 0.5 THEN 1 ELSE 0 END) AS stockout_days,
    ROUND(AVG(inventory_level), 2) AS avg_inventory,
    ROUND(AVG(demand_forecast), 2) AS avg_forecast
FROM inventory_transactions
GROUP BY product_id
ORDER BY stockout_days DESC;


-- 3.Supplier Performance Insights 

-- 4.Forecast demand trends based on seasonal/cyclical data
SELECT 
    p.category,
    DATE_FORMAT(it.date, '%Y-%m') AS month,
    
    CASE 
        WHEN MONTH(it.date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(it.date) IN (3, 4, 5, 6) THEN 'Summer'
        WHEN MONTH(it.date) IN (7, 8, 9) THEN 'Monsoon'
        WHEN MONTH(it.date) IN (10, 11) THEN 'Festive'
    END AS season,

    SUM(it.units_sold) AS total_units_sold,
    AVG(it.demand_forecast) AS avg_forecast
FROM inventory_transactions it
JOIN products p ON it.product_id = p.product_id
GROUP BY p.category, DATE_FORMAT(it.date, '%Y-%m'), season
ORDER BY p.category, month;

    
 




