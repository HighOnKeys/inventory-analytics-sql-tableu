-- Summary Report with KPIs

WITH
-- A. Stockout Rate
stockouts AS (
    SELECT 
        store_id, product_id,
        COUNT(*) AS total_days,
        SUM(CASE WHEN demand_forecast > inventory_level THEN 1 ELSE 0 END) AS stockout_days,
        ROUND(100.0 * SUM(CASE WHEN demand_forecast > inventory_level THEN 1 ELSE 0 END) / COUNT(*), 2) AS stockout_rate_percent
    FROM inventory_transactions
    GROUP BY store_id, product_id
),

-- B. Avg Inventory Age
inventory_age AS (
    SELECT 
        product_id,
        ROUND(AVG(inventory_level * 1.0 / NULLIF(units_sold, 0)), 2) AS avg_inventory_age_days
    FROM inventory_transactions
    GROUP BY product_id
),

-- C. Average Stock Level
avg_stock AS (
    SELECT 
        store_id, product_id,
        ROUND(AVG(inventory_level), 2) AS avg_stock_level
    FROM inventory_transactions
    GROUP BY store_id, product_id
),

-- D. Inventory Turnover
turnover AS (
    SELECT 
        product_id,
        SUM(units_sold) AS total_units_sold,
        ROUND(AVG(inventory_level), 2) AS avg_inventory,
        ROUND(SUM(units_sold) / NULLIF(AVG(inventory_level), 0), 2) AS inventory_turnover_ratio
    FROM inventory_transactions
    GROUP BY product_id
),

-- E. Reorder Point
reorder AS (
    SELECT 
        store_id, product_id,
        ROUND(AVG(units_sold), 2) AS avg_daily_sales,
        ROUND(AVG(units_sold) * 2, 2) AS reorder_point
    FROM inventory_transactions
    WHERE date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY store_id, product_id
)

-- Final Join
SELECT 
    s.store_id, s.product_id,
    s.stockout_rate_percent,
    a.avg_inventory_age_days,
    avg.avg_stock_level,
    t.inventory_turnover_ratio,
    r.reorder_point
FROM stockouts s
LEFT JOIN inventory_age a ON s.product_id = a.product_id
LEFT JOIN avg_stock avg ON s.store_id = avg.store_id AND s.product_id = avg.product_id
LEFT JOIN turnover t ON s.product_id = t.product_id
LEFT JOIN reorder r ON s.store_id = r.store_id AND s.product_id = r.product_id;

