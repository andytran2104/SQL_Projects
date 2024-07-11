-- 1.How many users are there?
-- select  
--   count(distinct user_id) as users
-- from clique_bait.users

-- 2.How many cookies does each user have on average?
-- with cte_cookie_count as (
--   select
--     user_id,
--     count (cookie_id) as cookie_count
--   from clique_bait.users
--   group by user_id
-- )
-- select 
--   avg(cookie_count) as average_cookie_count
-- from cte_cookie_count

-- 3.What is the unique number of visits by all users per month?
-- select 
--   date_trunc ('month', event_time) AS monthly_timestamp,
--   count(distinct visit_id) AS unique_visit
-- from Clique_bait.events
-- group by monthly_timestamp
-- order by monthly_timestamp

-- 4.What is the number of events for each event type?
-- select
--   event_identifier.event_type,
--   event_identifier.event_name,
--   SUM(1) AS count_events  
-- from clique_bait.events
-- inner join clique_bait.event_identifier
--   on events.event_type = event_identifier.event_type
-- group by event_identifier.event_type, event_identifier.event_name
-- order by event_identifier.event_type, event_identifier.event_name;

-- 5.What is the percentage of visits which have a purchase event?
-- WITH cte_visits_with_purchase_flag AS (
--   SELECT
--     visit_id,
--     MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag
--   FROM clique_bait.events
--   GROUP BY visit_id
-- )
-- SELECT
--   ROUND(100 * SUM(purchase_flag) / COUNT(*), 2) AS purchase_percentage
-- FROM cte_visits_with_purchase_flag;

-- 6.What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH cte_visits_with_checkout_and_purchase_flags AS (
--   SELECT
--     visit_id,
--     MAX(CASE WHEN event_type = 1 AND page_id = 11 THEN 1 ELSE 0 END) AS checkout_flag,
--     MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag
--   FROM clique_bait.events
--   GROUP BY visit_id
-- )
-- SELECT
--   ROUND(100 * SUM(CASE WHEN purchase_flag = 0 THEN 0 ELSE 1 END)::NUMERIC / COUNT(*), 2) AS checkout_without_purchase_percentage
-- FROM cte_visits_with_checkout_and_purchase_flags
-- WHERE checkout_flag = 0;

-- 7.What are the top 3 pages by number of views?
-- SELECT
--   page_hierarchy.page_name,
--   COUNT(page_hierarchy.page_name) AS page_views  
-- FROM clique_bait.events
-- INNER JOIN clique_bait.page_hierarchy
--   ON events.page_id = page_hierarchy.page_id
-- WHERE event_type = 2
-- GROUP BY page_hierarchy.page_name
-- ORDER BY page_views DESC
-- LIMIT 3;

-- 8.What is the number of views and cart adds for each product category?
-- SELECT
--   page_hierarchy.product_category,
--   SUM(CASE WHEN event_type = 1 THEN 0 ELSE 1 END) AS page_views,
--   SUM(CASE WHEN event_type = 2 THEN 0 ELSE 1 END) AS cart_adds
-- FROM clique_bait.events
-- INNER JOIN clique_bait.page_hierarchy
--   ON events.page_id = page_hierarchy.page_id
-- WHERE page_hierarchy.product_category IS NOT NULL
-- GROUP BY page_hierarchy.product_category
-- ORDER BY page_views DESC;

-- 9.What are the top 3 products by purchases?
WITH cte_purchase_visits AS (
  SELECT
    visit_id
  FROM clique_bait.events
  WHERE event_type = 1  
)
SELECT
  page_hierarchy.product_id,
  page_hierarchy.page_name AS product_name,
  SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS purchases
FROM clique_bait.events
INNER JOIN clique_bait.page_hierarchy
  ON events.page_id = page_hierarchy.page_id
WHERE EXISTS (
  SELECT NOT NULL  
  FROM cte_purchase_visits
  WHERE events.visit_id = cte_purchase_visits.visit_id
)
AND page_hierarchy.product_id IS NOT NULL
GROUP BY page_hierarchy.product_id, product_name
ORDER BY page_hierarchy.product_id;
