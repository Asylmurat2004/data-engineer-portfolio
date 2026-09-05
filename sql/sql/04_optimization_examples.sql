

-- ИНДЕКСЫ
CREATE INDEX idx_fact_sales_transaction_date ON dw.fact_sales(transaction_date);
CREATE INDEX idx_fact_sales_company_id ON dw.fact_sales(company_id);
CREATE INDEX idx_fact_sales_date_company ON dw.fact_sales(transaction_date, company_id);

-- MATERIALIZED VIEW
CREATE MATERIALIZED VIEW dw.sales_daily_summary AS
SELECT 
  company_id,
  transaction_date,
  COUNT(*) as transactions_count,
  SUM(amount) as total_amount,
  AVG(amount) as avg_amount,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count
FROM dw.fact_sales
GROUP BY company_id, transaction_date;

-- Обновление
REFRESH MATERIALIZED VIEW CONCURRENTLY dw.sales_daily_summary;

-- EXPLAIN для анализа
EXPLAIN ANALYZE
SELECT company_id, SUM(amount), COUNT(*)
FROM dw.fact_sales
WHERE transaction_date >= CURRENT_DATE - 30
GROUP BY company_id;
