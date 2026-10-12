-- Contrôles de reproductibilité du projet Northwind.
-- Lecture seule. Executer APRES SQL/07_kpi_views.sql.
-- Les valeurs attendues sont celles vérifiées dans l'environnement du projet en octobre 2026.
USE [Northwind];

-- 1. Contexte et version de SQL Server.
SELECT DB_NAME() AS BaseActive, @@VERSION AS VersionSQLServer;

-- 2. Volumétrie des 13 tables (la volumétrie ne suffit pas à prouver l'identité des données).
SELECT N'Categories' AS TableName, COUNT_BIG(*) AS NbLignes FROM dbo.Categories
UNION ALL SELECT N'CustomerCustomerDemo', COUNT_BIG(*) FROM dbo.CustomerCustomerDemo
UNION ALL SELECT N'CustomerDemographics', COUNT_BIG(*) FROM dbo.CustomerDemographics
UNION ALL SELECT N'Customers', COUNT_BIG(*) FROM dbo.Customers
UNION ALL SELECT N'Employees', COUNT_BIG(*) FROM dbo.Employees
UNION ALL SELECT N'EmployeeTerritories', COUNT_BIG(*) FROM dbo.EmployeeTerritories
UNION ALL SELECT N'Order Details', COUNT_BIG(*) FROM dbo.[Order Details]
UNION ALL SELECT N'Orders', COUNT_BIG(*) FROM dbo.Orders
UNION ALL SELECT N'Products', COUNT_BIG(*) FROM dbo.Products
UNION ALL SELECT N'Region', COUNT_BIG(*) FROM dbo.Region
UNION ALL SELECT N'Shippers', COUNT_BIG(*) FROM dbo.Shippers
UNION ALL SELECT N'Suppliers', COUNT_BIG(*) FROM dbo.Suppliers
UNION ALL SELECT N'Territories', COUNT_BIG(*) FROM dbo.Territories
ORDER BY TableName;

-- 3. Structure, contraintes, et nombres-clés.
SELECT
    (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0) AS NombreTables,
    (SELECT COUNT(*) FROM sys.foreign_keys) AS NombreFK,
    (SELECT COUNT(*) FROM sys.foreign_keys WHERE is_not_trusted = 1 OR is_disabled = 1) AS FKNonFiables,
    (SELECT COUNT(*) FROM sys.check_constraints) AS NombreChecks,
    (SELECT COUNT(*) FROM sys.check_constraints WHERE is_not_trusted = 1 OR is_disabled = 1) AS ChecksNonFiables,
    (SELECT COUNT_BIG(*) FROM dbo.Orders) AS NombreCommandes,
    (SELECT COUNT_BIG(*) FROM dbo.[Order Details]) AS LignesCommandes,
    (SELECT COUNT_BIG(*) FROM dbo.Customers) AS NombreClients,
    (SELECT COUNT_BIG(*) FROM dbo.Products) AS NombreProduits,
    (SELECT COUNT(*) FROM sys.views WHERE name LIKE N'v_bi_%') AS NombreVuesBI;

-- 4. Référence de CA : reproduction exacte de la convention de calcul du projet.
WITH C AS (
    SELECT SUM(
        CAST(Quantity AS DECIMAL(18,4))
        * CAST(UnitPrice AS DECIMAL(18,4))
        * (1 - CAST(Discount AS DECIMAL(18,4)))
    ) AS CA
    FROM dbo.[Order Details]
)
SELECT
    CAST(CA AS DECIMAL(28,4)) AS CA_Net_NonArrondi,
    CAST(ROUND(CA, 2) AS DECIMAL(28,2)) AS CA_Net_Arrondi,
    CASE WHEN ABS(CA - CAST(1265793.0395 AS DECIMAL(28,4))) < CAST(0.00005 AS DECIMAL(28,5))
         THEN N'PASS' ELSE N'A_CONTROLER' END AS StatutCA
FROM C;

-- 5. Volume de chacune des six vues de reporting.
SELECT N'Regional turnover' AS Vue, COUNT_BIG(*) AS NombreLignes FROM dbo.v_bi_regional_turnover_update
UNION ALL SELECT N'Order outliers', COUNT_BIG(*) FROM dbo.v_bi_order_value_outliers
UNION ALL SELECT N'Product performance', COUNT_BIG(*) FROM dbo.v_bi_product_performance_by_region
UNION ALL SELECT N'Shipping performance', COUNT_BIG(*) FROM dbo.v_bi_shipping_performance
UNION ALL SELECT N'Customer 360', COUNT_BIG(*) FROM dbo.v_bi_customer_360
UNION ALL SELECT N'Employee performance', COUNT_BIG(*) FROM dbo.v_bi_employee_performance
ORDER BY Vue;
