-- ============================================================================
-- 03_data_quality_checks.sql
-- ============================================================================

-- CHECK 1: NULL в ключевых полях
SELECT COUNT(*) as error_count
FROM dw.fact_sales
WHERE transaction_id IS NULL OR amount IS NULL;

-- CHECK 2: Значения > 0
SELECT COUNT(*) as error_count
FROM dw.fact_sales
WHERE amount <= 0;

-- CHECK 3: Каждая компания отправила данные
SELECT company_id, COUNT(*) as cnt
FROM dw.fact_sales
WHERE transaction_date = CURRENT_DATE - 1
GROUP BY company_id;

-- CHECK 4: Дубликаты
SELECT transaction_id, COUNT(*) as cnt
FROM dw.fact_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;
