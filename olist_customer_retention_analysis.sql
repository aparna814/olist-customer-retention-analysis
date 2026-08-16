-- 1. SETUP - ORDERS TABLE
CREATE TABLE orders (
     order_id VARCHAR(50),
     customer_id VARCHAR(50),
     order_status VARCHAR(30),
     order_purchase_timestamp DATETIME,
     order_approved_at DATETIME,
     order_delivered_carrier_date DATETIME,
     order_delivered_customer_date DATETIME,
     order_estimated_delivery_date DATETIME
    );
LOAD DATA LOCAL INFILE 'path/to/olist-orders_dataset.csv'
INTO TABLE orders 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. SETUP-CUSTOMER TABLE
CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
LOAD DATA LOCAL INFILE 'path/to/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. SETUP- REVIEWS TABLE
CREATE TABLE reviews (
	review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date VARCHAR(255),
    review_answer_timestamp VARCHAR(255)
);
LOAD DATA LOCAL INFILE 'path/to/olist_order_reviews_dataset.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 4. DATA VALIDATION
SELECT COUNT(*) AS total_orders
FROM orders;
SELECT COUNT(*) AS total_customers
FROM customers;
SELECT COUNT(*) AS total_reviews
FROM reviews;
SELECT
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM reviews) AS total_reviews;
-- 5. COHORT Retention Analysis
WITH customer_cohort AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(
            MIN(o.order_purchase_timestamp),
            '%Y%m'
        ) AS cohort_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

customer_orders_monthly AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y%m'
        ) AS order_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(*) AS total_customers
    FROM customer_cohort
    GROUP BY cohort_month
),

retention_raw AS (
    SELECT
        cc.cohort_month,
        PERIOD_DIFF(
            com.order_month,
            cc.cohort_month
        ) AS months_since_first_purchase,
        COUNT(DISTINCT cc.customer_unique_id) AS active_customers
    FROM customer_cohort cc
    JOIN customer_orders_monthly com
        ON cc.customer_unique_id = com.customer_unique_id
    GROUP BY
        cc.cohort_month,
        months_since_first_purchase
)

SELECT
    r.cohort_month,
    r.months_since_first_purchase,
    r.active_customers,
    s.total_customers,
    ROUND(
        r.active_customers / s.total_customers * 100,
        1
    ) AS retention_percent
FROM retention_raw r
JOIN cohort_size s
    ON r.cohort_month = s.cohort_month
ORDER BY
    r.cohort_month,
    r.months_since_first_purchase;

-- 6. DELIVERY PERFORMANCE & REPEAT CUSTOMER ANALYSIS

SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On-time/Early'
    END AS delivery_status,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT CASE
        WHEN rf.repeat_flag = 1
        THEN c.customer_unique_id
    END) AS repeat_customers,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN rf.repeat_flag = 1
            THEN c.customer_unique_id
        END)
        / COUNT(DISTINCT c.customer_unique_id) * 100,
        2
    ) AS repeat_rate_pct
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN (
    SELECT
        c2.customer_unique_id,
        CASE
            WHEN COUNT(DISTINCT o2.order_id) > 1
            THEN 1
            ELSE 0
        END AS repeat_flag
    FROM orders o2
    JOIN customers c2
        ON o2.customer_id = c2.customer_id
    GROUP BY c2.customer_unique_id
) rf
    ON c.customer_unique_id = rf.customer_unique_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status;

-- 7. REVIEW SCORE & REPEAT CUSTOMER ANALYSIS

SELECT
    CASE
        WHEN r.review_score <= 2 THEN 'Low (1-2 star)'
        ELSE 'High (4-5 star)'
    END AS review_group,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT CASE
        WHEN rf.repeat_flag = 1
        THEN c.customer_unique_id
    END) AS repeat_customers,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN rf.repeat_flag = 1
            THEN c.customer_unique_id
        END)
        / COUNT(DISTINCT c.customer_unique_id) * 100,
        2
    ) AS repeat_rate_pct
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN reviews r
    ON o.order_id = r.order_id
JOIN (
    SELECT
        c2.customer_unique_id,
        CASE
            WHEN COUNT(DISTINCT o2.order_id) > 1 THEN 1
            ELSE 0
        END AS repeat_flag
    FROM orders o2
    JOIN customers c2
        ON o2.customer_id = c2.customer_id
    GROUP BY c2.customer_unique_id
) rf
    ON c.customer_unique_id = rf.customer_unique_id
WHERE r.review_score IN (1, 2, 4, 5)
GROUP BY review_group;

-- Review score distribution
SELECT
    review_score,
    COUNT(*) AS num_reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score;

    
