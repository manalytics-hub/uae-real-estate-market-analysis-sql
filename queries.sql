-- ====================================================================
-- PROJECT: UAE Real Estate Market Analysis (SQL Production Scripts)
-- AUTHOR: Data Analyst Portfolio
-- SCOPE: Synthesizing Dubai & Abu Dhabi Real Estate Datasets
-- TECHNIQUES: DQL, Data Filtering, Aggregations, Set Operations
-- ====================================================================

-- --------------------------------------------------------------------
-- TASK 1: Premium Inventory Filtering
-- OBJECTIVE: Extract high-ticket, ready-to-move luxury properties.
-- --------------------------------------------------------------------
SELECT 
    property_id, 
    location, 
    property_type, 
    price, 
    status
FROM 
    dubai_properties
WHERE 
    status = 'Ready' 
    AND property_type IN ('Apartment', 'Villa')
    AND (location LIKE '%Marina%' OR location LIKE '%Downtown%' OR location LIKE '%Palm Jumeirah%')
    AND price > 2000000;


-- --------------------------------------------------------------------
-- TASK 2: Micro-Market Density & Valuation Analysis
-- OBJECTIVE: Identify top 5 premium areas by price per SQFT (Min. 50 listings).
-- --------------------------------------------------------------------
SELECT 
    location, 
    COUNT(property_id) AS total_listings,
    ROUND(AVG(price / size_sqft), 2) AS avg_price_per_sqft
FROM 
    dubai_properties
GROUP BY 
    location
HAVING 
    COUNT(property_id) >= 50
ORDER BY 
    avg_price_per_sqft DESC
LIMIT 5;


-- --------------------------------------------------------------------
-- TASK 3: Cross-Emirate Data Integration (Unified Portfolio)
-- OBJECTIVE: Combine regional inventory into a single master layout.
-- OPTIMIZATION NOTE: UNION ALL is used instead of UNION to avoid redundant distinct scans.
-- --------------------------------------------------------------------
SELECT 
    property_id, 
    location, 
    'Dubai' AS emirate, 
    property_type, 
    price 
FROM 
    dubai_properties

UNION ALL

SELECT 
    property_id, 
    location, 
    'Abu Dhabi' AS emirate, 
    property_type, 
    price 
FROM 
    abudhabi_properties;


-- --------------------------------------------------------------------
-- TASK 4: Omnipresent Developer Identification
-- OBJECTIVE: Pinpoint developers operating simultaneously in both markets.
-- --------------------------------------------------------------------
SELECT 
    developer_name, 
    property_type 
FROM 
    dubai_properties

INTERSECT

SELECT 
    developer_name, 
    property_type 
FROM 
    abudhabi_properties;


-- --------------------------------------------------------------------
-- TASK 5: Niche Market Gap Analysis (Dubai Exclusive Configurations)
-- OBJECTIVE: Discover property formats exclusive to Dubai to identify market gaps.
-- --------------------------------------------------------------------
SELECT 
    property_type, 
    bedrooms 
FROM 
    dubai_properties

EXCEPT

SELECT 
    property_type, 
    bedrooms 
FROM 
    abudhabi_properties;

-- --------------------------------------------------------------------
-- TASK 6: Enhance the format of data.
-- --------------------------------------------------------------------

-- 1. Standardize text input casing and spacing
SELECT UPPER(TRIM(location)) AS clean_location FROM dubai_properties;
SELECT LOWER(TRIM(status)) AS clean_status FROM abudhabi_properties;

-- 2. Extract substrings and count lengths
SELECT LEFT(developer_name, 10) AS short_dev_name FROM abudhabi_properties;
SELECT RIGHT(property_id, 5) AS short_id FROM dubai_properties;
SELECT LENGTH(property_type) AS text_len FROM dubai_properties;

-- 3. Combine strings together
SELECT CONCAT(location, ' - ', property_type) AS property_full_title FROM dubai_properties;

-- 4. Locate characters and find positions
SELECT POSITION('penthouse' IN LOWER(property_type)) AS keyword_index FROM dubai_properties;
SELECT INSTR(LOWER(property_type), 'villa') AS keyword_position FROM abudhabi_properties;

-- 5. Replace characters within a string
SELECT REPLACE(location, 'Marina', 'Harbour') AS updated_location FROM dubai_properties;

-- 6. Combine multiple functions together
SELECT CONCAT(LEFT(developer_name, 12), '...') AS visual_title FROM abudhabi_properties;

-- ====================================================================
-- TASK 7: Aggregate Functions Analysis
-- OBJECTIVE: Utilize various aggregate functions for market insights.
-- ====================================================================

-- 7.1 SUM() - Total market value by property type
-- OBJECTIVE: Calculate total investment value for each property type
-- TECHNIQUE: SUM() with GROUP BY for portfolio analysis
SELECT 
    property_type,
    COUNT(property_id) AS property_count,
    SUM(price) AS total_market_value,
    ROUND(SUM(price) / 1000000, 2) AS total_value_millions
FROM 
    dubai_properties
GROUP BY 
    property_type
ORDER BY 
    total_market_value DESC;


-- 7.2 MAX() & MIN() - Price range analysis by location
-- OBJECTIVE: Identify price boundaries in premium areas
-- TECHNIQUE: MAX() and MIN() for market extremes
SELECT 
    location,
    COUNT(property_id) AS total_listings,
    MIN(price) AS lowest_price,
    MAX(price) AS highest_price,
    (MAX(price) - MIN(price)) AS price_range,
    ROUND((MAX(price) - MIN(price)) / MIN(price) * 100, 2) AS price_variance_percent
FROM 
    dubai_properties
GROUP BY 
    location
HAVING 
    COUNT(property_id) >= 20
ORDER BY 
    price_range DESC;


-- 7.3 AVG() - Average metrics by developer performance
-- OBJECTIVE: Evaluate developer pricing strategy
-- TECHNIQUE: AVG() for performance benchmarking
SELECT 
    developer_name,
    COUNT(property_id) AS properties_listed,
    ROUND(AVG(price), 2) AS avg_property_price,
    ROUND(AVG(size_sqft), 2) AS avg_property_size,
    ROUND(AVG(price / size_sqft), 2) AS avg_price_per_sqft
FROM 
    dubai_properties
GROUP BY 
    developer_name
HAVING 
    COUNT(property_id) >= 5
ORDER BY 
    avg_property_price DESC;


-- 7.4 COUNT() - Market composition and distribution
-- OBJECTIVE: Analyze property type distribution across emirates
-- TECHNIQUE: COUNT() with DISTINCT for uniqueness metrics
SELECT 
    property_type,
    COUNT(*) AS total_properties,
    COUNT(DISTINCT developer_name) AS unique_developers,
    COUNT(DISTINCT location) AS unique_locations,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM dubai_properties), 2) AS market_share_percent
FROM 
    dubai_properties
GROUP BY 
    property_type
ORDER BY 
    total_properties DESC;


-- 7.5 Combined Aggregates - Comprehensive market dashboard
-- OBJECTIVE: Multi-dimensional analysis for strategic insights
-- TECHNIQUE: Multiple aggregate functions in single query
SELECT 
    bedrooms,
    property_type,
    COUNT(property_id) AS unit_count,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(price) / 1000000, 2) AS total_value_millions,
    ROUND(AVG(size_sqft), 2) AS avg_sqft,
    ROUND(AVG(price / size_sqft), 2) AS avg_price_sqft
FROM 
    dubai_properties
WHERE 
    status = 'Ready'
GROUP BY 
    bedrooms, 
    property_type
HAVING 
    COUNT(property_id) >= 10
ORDER BY 
    unit_count DESC;


-- 7.6 Cross-Emirate Aggregate Comparison
-- OBJECTIVE: Compare market metrics between Dubai and Abu Dhabi
-- TECHNIQUE: Union of separate aggregates for comparative analysis
SELECT 
    'Dubai' AS emirate,
    COUNT(property_id) AS total_properties,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(SUM(price) / 1000000, 2) AS total_market_value_millions
FROM 
    dubai_properties

UNION ALL

SELECT 
    'Abu Dhabi' AS emirate,
    COUNT(property_id) AS total_properties,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(SUM(price) / 1000000, 2) AS total_market_value_millions
FROM 
    abudhabi_properties;


-- 7.7 Location Performance Scorecard
-- OBJECTIVE: Rank locations by multiple metrics
-- TECHNIQUE: Nested aggregates with ROUND() for precision
SELECT 
    location,
    COUNT(property_id) AS listing_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(price) / 1000000, 2) AS total_market_value_millions,
    ROUND(AVG(bedrooms), 1) AS avg_bedrooms,
    ROUND(AVG(size_sqft), 2) AS avg_property_size,
    COUNT(DISTINCT developer_name) AS developer_count,
    ROUND((COUNT(DISTINCT status) - 1), 0) AS status_variety
FROM 
    dubai_properties
GROUP BY 
    location
ORDER BY 
    total_market_value_millions DESC
LIMIT 10;
