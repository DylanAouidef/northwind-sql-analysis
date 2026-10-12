# Mapping SQL Server → Looker Studio (mise à jour du 12 octobre 2026)

Les **six vues SQL** correspondent maintenant aux **six sources CSV conservées** dans le rapport. Le nettoyage des sources Looker Studio a réduit le total de **12 à 6** ; une combinaison croisée et une source « Employee by Customer Country » ont été remplacées pour l'indicateur *Top Performer Revenue Share*.

| Vue SQL | Nom de la source actuellement affiché dans Looker Studio | Graphiques utilisant la source | Validation disponible |
|---|---|---:|---|
| `dbo.v_bi_regional_turnover_update` | `Northwind | v_bi_regional_turnover_update | CSV` | 6 | Champs et plusieurs valeurs des **21 pays** comparés visuellement entre SQL et Looker ; comparaison exhaustive de tous les champs non effectuée |
| `dbo.v_bi_order_value_outliers` | `v_bi_order_value_outliers` | 1 | Nom et présence dans le rapport ; contrôle de valeurs CSV ligne par ligne non effectué |
| `dbo.v_bi_product_performance_by_region` | `v_bi_product_performance_by_region` | 8 | Nom et présence dans le rapport ; contrôle de valeurs CSV ligne par ligne non effectué |
| `dbo.v_bi_shipping_performance` | `v_bi_shipping_performance_2.0` | 8 | Correspondance nominale et fonctionnelle ; contrôle de valeurs CSV ligne par ligne non effectué |
| `dbo.v_bi_customer_360` | `v_bi_customer_360_2.0` | 8 | Correspondance nominale et fonctionnelle ; contrôle de valeurs CSV ligne par ligne non effectué |
| `dbo.v_bi_employee_performance` | `v_bi_employee_performance` | 8 | Source avec **9 employés** ; le nouvel indicateur automatique *Top Performer Revenue Share* a reproduit **18,40 %** à l'affichage |

**Total observé dans l'interface : 39 utilisations par des graphiques.** Ces compteurs sont fournis par Looker Studio et ne signifient pas 39 sources indépendantes.

## Traçabilité vérifiée sur des cas précis

- Le CSV anciennement nommé `RTD2.0` a été renommé avec sa provenance SQL explicite. Ses champs (`ShipCountry`, `GrossTurnover`, `NetTurnover`, `NumberOfOrders`, `TotalDiscountAmount`) et un échantillon de valeurs visibles concordent avec la vue SQL correspondante.
- La source `Employee_360` suivait une granularité *employé × pays client* (167 lignes) ; les requêtes SQL ont retrouvé 167 combinaisons et trois montants illustratifs. Cette source a finalement été **retirée du rapport** : elle ne fait **plus** partie du mapping final.
- Le scorecard de part du meilleur vendeur se calcule maintenant depuis `v_bi_employee_performance`, selon **`MAX(NetRevenueGenerated) / SUM(NetRevenueGenerated)`**, sans filtre fixe sur Margaret Peacock ni source combinée croisée. Il affiche 18,40 % dans la configuration actuelle. La mesure dépend toujours du périmètre et des filtres appliqués au graphique.
- Les noms de sources dans Looker Studio sont des **libellés de source** et ne prouvent pas le nom exact des fichiers CSV enregistrés sur disque.

## Exporter les six sources depuis DBeaver

1. Exécuter `SQL/07_kpi_views.sql`, puis `SQL/10_exports_looker_studio.sql`.
2. Exporter les **six jeux de résultats complets** vers des fichiers CSV en UTF-8 avec en-têtes, sans tronquer à la limite d'aperçu DBeaver.
3. Vérifier le nombre de lignes attendues dans l'environnement audité : **21, 830, 2 038, 809, 89, 9** selon l'ordre des vues du README.
4. Vérifier l'interprétation des dates et des nombres à l'import dans Looker Studio. Les CSV importés **ne sont pas synchronisés en temps réel** avec SQL Server.
5. Comparer les indicateurs et filtres de chaque page aux résultats SQL en tenant compte de la granularité et des exclusions éventuelles.

## Actualisation de la page Product Performance

Le graphique temporel « Monthly Sales Volume by Category » a été remplacé dans le **rapport vivant** par des **colonnes empilées classiques**, et non par des colonnes 100 % empilées. La capture `screenshots/page2_products.png` montre désormais ce graphique en colonnes empilées classiques ; son format PNG a été vérifié avant publication. Le changement de visualisation n'implique pas de nouveau jeu de données.

## Contrôles encore à réaliser pour une reproduction intégrale

- Comparaison **exhaustive** des valeurs CSV/SQL pour les autres sources ; captures partielles ne suffisent pas à prouver une identité complète.
- Documentation complète des filtres et champs calculés par graphique sur les cinq pages.
- Reproduction de toutes les interactions sur une instance Looker Studio indépendante.
- Vérification en mode lecture des cinq pages après nettoyage ; la liste des six sources indique « Fonctionnelle » mais ce statut ne suffit pas à tester tous les filtres.
