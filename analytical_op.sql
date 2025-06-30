-- analytical outputs

-- 1. identify Fast-Selling vs. Slow-Moving Products
 
SELECT 
    product_id,
    SUM(units_sold) AS total_sales
FROM inventory_transactions
GROUP BY product_id
ORDER BY total_sales DESC;

-- 2. recommend Stock Adjustments to Reduce Holding Cost
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


-- 3.supplier Performance Insights 

-- 4.forecast demand trends based on seasonal/cyclical data
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

    
 




