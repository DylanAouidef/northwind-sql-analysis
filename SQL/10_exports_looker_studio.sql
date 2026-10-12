-- 6 requêtes d'export, une par vue BI.
-- Lecture seule ; exécuter après 07_kpi_views.sql.
-- Chaque SELECT produit un jeu de résultats distinct à exporter en CSV intégral dans DBeaver.
-- Respecter la convention des noms de fichiers indiquée dans docs/MAPPING_LOOKER_STUDIO.md.
USE [Northwind];

-- 1. regional_turnover.csv (attendu : 21 lignes)
SELECT * FROM dbo.v_bi_regional_turnover_update;

-- 2. order_value_outliers.csv (attendu : 830 lignes)
SELECT * FROM dbo.v_bi_order_value_outliers;

-- 3. product_performance_by_region.csv (attendu : 2038 lignes)
SELECT * FROM dbo.v_bi_product_performance_by_region;

-- 4. shipping_performance.csv (attendu : 809 lignes)
SELECT * FROM dbo.v_bi_shipping_performance;

-- 5. customer_360.csv (attendu : 89 lignes)
SELECT * FROM dbo.v_bi_customer_360;

-- 6. employee_performance.csv (attendu : 9 lignes)
SELECT * FROM dbo.v_bi_employee_performance;
