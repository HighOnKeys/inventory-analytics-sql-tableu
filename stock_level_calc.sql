 -- current stock level calculation  
SELECT
    store_id,
    product_id,
    MAX(date) AS latest_date,
    SUBSTRING_INDEX(GROUP_CONCAT(inventory_level ORDER BY date DESC), ',', 1) AS inventory_level
FROM inventory_transactions
GROUP BY store_id, product_id
ORDER BY store_id, product_id;

-- low inventory detection 

SELECT
    store_id,
    product_id,
    MAX(date) AS latest_date,
    SUBSTRING_INDEX(GROUP_CONCAT(inventory_level ORDER BY date DESC), ',', 1) AS current_inventory,
    SUBSTRING_INDEX(GROUP_CONCAT(demand_forecast ORDER BY date DESC), ',', 1) AS latest_forecast
FROM inventory_transactions
GROUP BY store_id, product_id
HAVING current_inventory < latest_forecast
ORDER BY store_id, product_id;

--  reorder point estimation
SELECT 
    store_id, product_id,
    AVG(units_sold) AS avg_daily_sales,
    MAX(units_sold) AS max_daily_sales,
    AVG(units_sold) * 2 AS reorder_point -- lead time ~2 days
FROM inventory_transactions
WHERE date >= CURDATE() - INTERVAL 30 DAY
GROUP BY store_id, product_id;

-- inventory turnoveer ratio 
SELECT 
    product_id,
    SUM(units_sold) / NULLIF(AVG(inventory_level), 0) AS inventory_turnover_ratio
FROM inventory_transactions
GROUP BY product_id;



