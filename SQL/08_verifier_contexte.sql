-- Vérification du contexte : À exécuter après ouverture d’un script.
-- Ce fichier ne modifie aucune donnée.
USE [Northwind];
SELECT DB_NAME() AS BaseActive;

-- 13 tables Northwind attendues (le nombre de tables seul ne valide pas leur contenu).
SELECT COUNT(*) AS NombreTables
FROM Northwind.sys.tables
WHERE is_ms_shipped = 0;

-- À exécuter seulement après SQL/07_kpi_views.sql.
SELECT name AS VueBI
FROM Northwind.sys.views
WHERE name LIKE N'v_bi_%'
ORDER BY name;
