-- ============================================================================
-- 02_deduplication.sql
-- Last Win - выбор последней версии
-- ============================================================================

WITH ranked AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY loaded_at DESC) as rn
  FROM dw.fact_sales
)
SELECT * FROM ranked WHERE rn = 1;

-- ROW_NUMBER(): номер в группе
-- PARTITION BY: группировка по ключу
-- ORDER BY DESC: новое первое
-- WHERE rn = 1: оставляем последнее
