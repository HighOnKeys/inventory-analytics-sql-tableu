CREATE DATABASE IF NOT EXISTS Inventory;
USE Inventory;
CREATE TABLE stores (
    store_id VARCHAR(10) PRIMARY KEY,
    region VARCHAR(50)
);
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    category VARCHAR(50)
);
CREATE TABLE inventory_transactions (
    date DATE,
    store_id VARCHAR(10),
    product_id VARCHAR(10),
    inventory_level INT,
    units_sold INT,
    units_ordered INT,
    demand_forecast FLOAT,
    price FLOAT,
    discount INT,
    weather_condition VARCHAR(20),
    holiday_promotion BOOLEAN,
    competitor_pricing FLOAT,
    seasonality VARCHAR(20),
    PRIMARY KEY (date, store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE temp_inventory (
    Date VARCHAR(20),
    `Store ID` VARCHAR(10),
    `Product ID` VARCHAR(10),
    Category VARCHAR(50),
    Region VARCHAR(50),
    `Inventory Level` INT,
    `Units Sold` INT,
    `Units Ordered` INT,
    `Demand Forecast` FLOAT,
    Price FLOAT,
    Discount INT,
    `Weather Condition` VARCHAR(20),
    `Holiday/Promotion` BOOLEAN,
    `Competitor Pricing` FLOAT,
    Seasonality VARCHAR(20)
);

-- insert stores
INSERT IGNORE INTO stores (store_id, region)
SELECT DISTINCT `Store ID`, Region FROM temp_inventory;

-- insert products
INSERT IGNORE INTO products (product_id, category)
SELECT DISTINCT `Product ID`, Category FROM temp_inventory;

-- insert transactions
INSERT IGNORE INTO inventory_transactions (
    date, store_id, product_id, inventory_level,
    units_sold, units_ordered, demand_forecast,
    price, discount, weather_condition,
    holiday_promotion, competitor_pricing, seasonality
)
SELECT 
    STR_TO_DATE(Date, '%Y-%m-%d'),
    `Store ID`, `Product ID`, `Inventory Level`,
    `Units Sold`, `Units Ordered`, `Demand Forecast`,
    Price, Discount, `Weather Condition`,
    `Holiday/Promotion`, `Competitor Pricing`, Seasonality
FROM temp_inventory;


