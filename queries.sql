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

