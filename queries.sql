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
SELECT 
    location,
    COUNT(property_id) AS total_listings,
    MIN(price) AS lowest_price,
    MAX(price) AS highest_price,
    (MAX(price) - MIN(price)) AS price_range
FROM 
    dubai_properties
GROUP BY 
    location
HAVING 
    COUNT(property_id) >= 20
ORDER BY 
    price_range DESC;


-- 7.3 AVG() - Average metrics by developer performance
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
SELECT 
    property_type,
    COUNT(*) AS total_properties,
    COUNT(DISTINCT developer_name) AS unique_developers,
    COUNT(DISTINCT location) AS unique_locations
FROM 
    dubai_properties
GROUP BY 
    property_type
ORDER BY 
    total_properties DESC;


-- 7.5 Combined Aggregates - Comprehensive market dashboard
SELECT 
    bedrooms,
    property_type,
    COUNT(property_id) AS unit_count,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(price) / 1000000, 2) AS total_value_millions
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
SELECT 
    location,
    COUNT(property_id) AS listing_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(price) / 1000000, 2) AS total_market_value_millions
FROM 
    dubai_properties
GROUP BY 
    location
ORDER BY 
    total_market_value_millions DESC
LIMIT 10;

-- ====================================================================
-- TASK 8: Window Functions - Rank Functions Analysis
-- OBJECTIVE: Apply ranking functions for market positioning analysis.
-- TECHNIQUES: ROW_NUMBER, RANK, DENSE_RANK for competitive analysis
-- ====================================================================

-- 8.1 ROW_NUMBER() - Top Properties by Price in Each Location
-- OBJECTIVE: Rank each property by price within its location
SELECT 
    property_id,
    location,
    property_type,
    price,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY price DESC) AS price_rank
FROM 
    dubai_properties
ORDER BY 
    location, 
    price_rank;


-- 8.2 RANK() - Properties Ranked by Price
-- OBJECTIVE: Rank all properties by their price (with ties)
SELECT 
    property_id,
    property_type,
    price,
    bedrooms,
    RANK() OVER (ORDER BY price DESC) AS price_rank
FROM 
    dubai_properties
ORDER BY 
    price_rank;


-- 8.3 DENSE_RANK() - Properties Ranked by Price
-- OBJECTIVE: Rank all properties by price without gaps
SELECT 
    property_id,
    location,
    price,
    DENSE_RANK() OVER (ORDER BY price DESC) AS price_rank
FROM 
    dubai_properties
ORDER BY 
    price_rank;


-- 8.4 ROW_NUMBER() - Ranking by Property Type
-- OBJECTIVE: Rank properties within each property type by price
SELECT 
    property_id,
    property_type,
    bedrooms,
    price,
    ROUND(price / size_sqft, 2) AS price_per_sqft,
    ROW_NUMBER() OVER (PARTITION BY property_type ORDER BY price DESC) AS rank_in_type
FROM 
    dubai_properties
ORDER BY 
    property_type,
    rank_in_type;


-- 8.5 RANK() - Rank All Properties by Location
-- OBJECTIVE: Rank properties by location average price
SELECT 
    property_id,
    location,
    price,
    RANK() OVER (ORDER BY price DESC) AS overall_rank
FROM 
    dubai_properties
ORDER BY 
    overall_rank;


-- 8.6 DENSE_RANK() - Price Segment Classification
-- OBJECTIVE: Rank properties by price range
SELECT 
    property_id,
    location,
    bedrooms,
    price,
    DENSE_RANK() OVER (ORDER BY price) AS price_rank
FROM 
    dubai_properties
ORDER BY 
    price;


-- 8.7 ROW_NUMBER() - Top Property in Each Location
-- OBJECTIVE: Find the most expensive property in each location
SELECT 
    property_id,
    location,
    property_type,
    price,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY price DESC) AS rank_in_location
FROM 
    dubai_properties
ORDER BY 
    location,
    rank_in_location;


-- 8.8 RANK() - Rank Properties by Size
-- OBJECTIVE: Rank all properties by their size in sqft
SELECT 
    property_id,
    location,
    size_sqft,
    price,
    RANK() OVER (ORDER BY size_sqft DESC) AS size_rank
FROM 
    dubai_properties
ORDER BY 
    size_rank;


-- 8.9 DENSE_RANK() - Rank Properties by Bedrooms
-- OBJECTIVE: Rank properties by number of bedrooms
SELECT 
    property_id,
    bedrooms,
    price,
    DENSE_RANK() OVER (ORDER BY bedrooms DESC) AS bedroom_rank
FROM 
    dubai_properties
ORDER BY 
    bedroom_rank;


-- 8.10 ROW_NUMBER() - Rank Properties in Each Bedroom Category
-- OBJECTIVE: Rank properties within each bedroom count by price
SELECT 
    property_id,
    bedrooms,
    price,
    location,
    ROW_NUMBER() OVER (PARTITION BY bedrooms ORDER BY price DESC) AS rank_in_bedroom_category
FROM 
    dubai_properties
ORDER BY 
    bedrooms,
    rank_in_bedroom_category;
