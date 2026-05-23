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
