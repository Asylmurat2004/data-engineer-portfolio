-- ============================================================================
-- 01_union_consolidation.sql
-- ============================================================================

SELECT 
  transaction_id AS sale_id,
  1 AS company_id,
  date::date AS transaction_date,
  amount,
  product_id,
  status,
  NOW() AS loaded_at
FROM sources.sales_child_1

UNION ALL

SELECT 
  order_id::text AS sale_id,
  2 AS company_id,
  created_at::date AS transaction_date,
  sum AS amount,
  item_id AS product_id,
  state AS status,
  NOW() AS loaded_at
FROM sources.sales_child_2;

-- UNION ALL: быстрее, не удаляет дубликаты
-- ::text, ::date: приведение типов
-- company_id = 1 или 2: источник данных
