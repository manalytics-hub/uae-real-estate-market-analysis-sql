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

-- ====================================================================
-- TASK 8: Window Functions - Rank Functions Analysis
-- OBJECTIVE: Apply ranking and analytical window functions for competitive analysis.
-- TECHNIQUES: ROW_NUMBER, RANK, DENSE_RANK, NTILE for market positioning
-- ====================================================================

-- 8.1 ROW_NUMBER() - Unique Sequential Ranking
-- OBJECTIVE: Assign unique row numbers to properties ordered by price
-- TECHNIQUE: ROW_NUMBER() with PARTITION BY for category-based ranking
-- USE CASE: Identify top 3 most expensive properties in each location
SELECT 
    property_id,
    location,
    property_type,
    price,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY price DESC) AS price_rank_in_location,
    ROW_NUMBER() OVER (PARTITION BY property_type ORDER BY price DESC) AS price_rank_by_type
FROM 
    dubai_properties
WHERE 
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY price DESC) <= 3;


-- 8.2 RANK() - Handle Ties with Gaps
-- OBJECTIVE: Rank properties by price, allowing ties and gaps
-- TECHNIQUE: RANK() for competitive positioning analysis
-- USE CASE: Find developers' market position based on average property price
SELECT 
    developer_name,
    ROUND(AVG(price), 2) AS avg_price,
    RANK() OVER (ORDER BY AVG(price) DESC) AS developer_price_rank,
    COUNT(property_id) AS property_count
FROM 
    dubai_properties
GROUP BY 
    developer_name
HAVING 
    COUNT(property_id) >= 3
ORDER BY 
    developer_price_rank;


-- 8.3 DENSE_RANK() - Consecutive Ranking Without Gaps
-- OBJECTIVE: Rank locations by market value, no gaps in ranking
-- TECHNIQUE: DENSE_RANK() for tier classification
-- USE CASE: Identify tier-1, tier-2, and tier-3 market locations
SELECT 
    location,
    ROUND(SUM(price) / 1000000, 2) AS total_market_value_millions,
    COUNT(property_id) AS listing_count,
    DENSE_RANK() OVER (ORDER BY SUM(price) DESC) AS market_tier,
    CASE 
        WHEN DENSE_RANK() OVER (ORDER BY SUM(price) DESC) = 1 THEN 'Premium Tier'
        WHEN DENSE_RANK() OVER (ORDER BY SUM(price) DESC) <= 5 THEN 'Mid Tier'
        ELSE 'Entry Tier'
    END AS tier_classification
FROM 
    dubai_properties
GROUP BY 
    location
ORDER BY 
    market_tier;


-- 8.4 NTILE() - Quartile & Percentile Distribution
-- OBJECTIVE: Segment properties into quartiles by price
-- TECHNIQUE: NTILE(4) for quantile analysis
-- USE CASE: Price bracket segmentation for investment strategy
SELECT 
    property_id,
    location,
    property_type,
    price,
    bedrooms,
    NTILE(4) OVER (ORDER BY price) AS price_quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY price) = 1 THEN 'Budget'
        WHEN NTILE(4) OVER (ORDER BY price) = 2 THEN 'Standard'
        WHEN NTILE(4) OVER (ORDER BY price) = 3 THEN 'Premium'
        WHEN NTILE(4) OVER (ORDER BY price) = 4 THEN 'Luxury'
    END AS price_segment
FROM 
    dubai_properties
WHERE 
    status = 'Ready';


-- 8.5 Combined Ranking Functions - Developer Performance Dashboard
-- OBJECTIVE: Comprehensive ranking analysis across multiple dimensions
-- TECHNIQUE: Multiple ranking functions in single query
-- USE CASE: Identify top-performing developers in different segments
SELECT 
    developer_name,
    property_type,
    COUNT(property_id) AS portfolio_size,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(price / size_sqft), 2) AS avg_price_per_sqft,
    ROW_NUMBER() OVER (PARTITION BY property_type ORDER BY COUNT(property_id) DESC) AS volume_rank_by_type,
    RANK() OVER (ORDER BY AVG(price) DESC) AS overall_price_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(property_id) DESC) AS portfolio_size_rank
FROM 
    dubai_properties
GROUP BY 
    developer_name, 
    property_type
HAVING 
    COUNT(property_id) >= 2
ORDER BY 
    property_type, 
    portfolio_size DESC;


-- 8.6 Property Position Within Location Market
-- OBJECTIVE: Show each property's position within its location's price range
-- TECHNIQUE: ROW_NUMBER() + PERCENT_RANK()-like calculation
-- USE CASE: Identify under/overpriced properties in specific locations
SELECT 
    property_id,
    location,
    price,
    bedrooms,
    ROUND(AVG(price) OVER (PARTITION BY location), 2) AS location_avg_price,
    ROUND(MIN(price) OVER (PARTITION BY location), 2) AS location_min_price,
    ROUND(MAX(price) OVER (PARTITION BY location), 2) AS location_max_price,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY price DESC) AS price_position_in_location,
    CASE 
        WHEN price > (AVG(price) OVER (PARTITION BY location)) * 1.2 THEN 'Premium Priced'
        WHEN price < (AVG(price) OVER (PARTITION BY location)) * 0.8 THEN 'Bargain Opportunity'
        ELSE 'Market Average'
    END AS price_positioning
FROM 
    dubai_properties
WHERE 
    location IN (SELECT location FROM dubai_properties GROUP BY location HAVING COUNT(*) >= 15)
ORDER BY 
    location, 
    price DESC;


-- 8.7 Cumulative Market Share Analysis
-- OBJECTIVE: Track cumulative market value distribution by developer
-- TECHNIQUE: ROW_NUMBER() + SUM() as running total
-- USE CASE: Identify market concentration and top developers' dominance
WITH developer_market_value AS (
    SELECT 
        developer_name,
        COUNT(property_id) AS property_count,
        ROUND(SUM(price) / 1000000, 2) AS market_value_millions,
        RANK() OVER (ORDER BY SUM(price) DESC) AS market_rank
    FROM 
        dubai_properties
    GROUP BY 
        developer_name
)
SELECT 
    developer_name,
    market_rank,
    property_count,
    market_value_millions,
    ROUND(
        100.0 * SUM(market_value_millions) OVER (ORDER BY market_rank) / 
        (SELECT SUM(market_value_millions) FROM developer_market_value),
        2
    ) AS cumulative_market_share_percent
FROM 
    developer_market_value
ORDER BY 
    market_rank
LIMIT 10;


-- 8.8 Competitive Positioning by Property Type & Price Segment
-- OBJECTIVE: Rank properties against peers in same type and price range
-- TECHNIQUE: ROW_NUMBER() with multi-level PARTITION BY
-- USE CASE: Compare similar properties to identify premium features
SELECT 
    property_id,
    property_type,
    bedrooms,
    price,
    size_sqft,
    ROUND(price / size_sqft, 2) AS price_per_sqft,
    ROW_NUMBER() OVER (PARTITION BY property_type, bedrooms ORDER BY price DESC) AS rank_in_category,
    RANK() OVER (PARTITION BY property_type, bedrooms ORDER BY price / size_sqft DESC) AS efficiency_rank,
    COUNT(*) OVER (PARTITION BY property_type, bedrooms) AS total_in_category
FROM 
    dubai_properties
WHERE 
    property_type IN ('Apartment', 'Villa')
    AND bedrooms IN (2, 3, 4)
    AND status = 'Ready'
ORDER BY 
    property_type, 
    bedrooms, 
    rank_in_category;


-- 8.9 Market Tier Segmentation with NTILE()
-- OBJECTIVE: Divide locations into equal performance tiers
-- TECHNIQUE: NTILE(3) for tertile analysis
-- USE CASE: Strategic investment planning by market tier
SELECT 
    location,
    ROUND(SUM(price) / 1000000, 2) AS total_market_value,
    COUNT(property_id) AS listing_count,
    ROUND(AVG(price), 2) AS avg_price,
    NTILE(3) OVER (ORDER BY AVG(price) DESC) AS performance_tier,
    CASE 
        WHEN NTILE(3) OVER (ORDER BY AVG(price) DESC) = 1 THEN 'Premium Market'
        WHEN NTILE(3) OVER (ORDER BY AVG(price) DESC) = 2 THEN 'Growing Market'
        ELSE 'Emerging Market'
    END AS market_segment
FROM 
    dubai_properties
GROUP BY 
    location
HAVING 
    COUNT(property_id) >= 10
ORDER BY 
    performance_tier,
    avg_price DESC;


-- 8.10 Cross-Emirate Competitive Ranking
-- OBJECTIVE: Compare property rankings between Dubai and Abu Dhabi
-- TECHNIQUE: ROW_NUMBER() with emirate partition
-- USE CASE: Identify competitive pricing differences between markets
SELECT 
    emirate,
    location,
    property_type,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(property_id) AS listing_count,
    ROW_NUMBER() OVER (PARTITION BY emirate ORDER BY AVG(price) DESC) AS emirate_rank,
    RANK() OVER (ORDER BY AVG(price) DESC) AS cross_emirate_rank
FROM (
    SELECT 'Dubai' AS emirate, location, property_type, price FROM dubai_properties
    UNION ALL
    SELECT 'Abu Dhabi' AS emirate, location, property_type, price FROM abudhabi_properties
)
GROUP BY 
    emirate, location, property_type
HAVING 
    COUNT(property_id) >= 5
ORDER BY 
    emirate, 
    emirate_rank;
