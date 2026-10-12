# Northwind — Recommandations métiers et plan d’action

**Statut :** propositions d’analyse et de décision, **non déployées**.  
**Périmètre :** données historiques Northwind (1996–1998), six vues SQL Server et dashboard Looker Studio.  
**Méthode :** constat mesuré → décision envisageable → vérification complémentaire → indicateur de suivi → limite.

> Les montants et ratios ci-dessous proviennent du README et du dashboard du projet, et non de résultats d’actions réellement entreprises. Les chiffres doivent être vérifiés dans le contexte d’analyse documenté ; une corrélation descriptive ne démontre pas une causalité.

## Synthèse pour un responsable métier

| Priorité d’investigation | Fait observé | Décision à instruire | À mesurer |
|---|---|---|---|
| 1 — Fidélisation | **10 clients** classés *At Risk / High Value* parmi **89 clients acheteurs** | Revoir leurs comptes et, si pertinent, tester une relance ciblée | Part des comptes recontactés, taux de réponse, taux de réactivation, CA ultérieur |
| 2 — Pilotage produit | **Beverages ≈ 267,9 k$**, **Dairy Products ≈ 234,5 k$**, soit **≈ 40 % du CA net** réunies | Distinguer la gestion des références à fort CA et des références à forte demande physique | Part du CA, unités vendues, fréquence des commandes ; puis ruptures et rotation si données complémentaires |
| 3 — Expédition | **8,49 j** entre commande et expédition en moyenne ; **4,57 %** de départs après la date requise | Auditer les écarts de délais par transporteur, destination et type de commande | Délai de préparation, taux d’expédition tardive, effectifs comparables et évolution par segment |

Les priorités sont proposées pour organiser l’investigation ; **elles ne constituent pas une estimation chiffrée d’impact ou de retour sur investissement**.

## 1. Fidélisation : traiter les comptes à forte valeur devenus moins récents

### Constat étayé

La segmentation RFM documentée classe **30 clients** en *Champions / VIP* et **10 clients** en *At Risk / High Value* (sur les **89 clients ayant acheté**). Un exemple est **Mère Paillarde**, avec **28 872,19 $** d’achats nets historiques et **188 jours de récence** au **point de référence du jeu de données**, et non à la date d’aujourd’hui.

### Hypothèse et recommandation

Ces dix comptes **méritent une revue commerciale prioritaire**, car un historique de forte valeur combiné à une récence défavorable peut signaler une opportunité de fidélisation. **Ne pas conclure qu’ils ont quitté l’entreprise** : la fréquence normale d’achat, les contrats et les interactions commerciales ne figurent pas dans ces données.

**Plan d’action proposé :**

1. Extraire les dix comptes, leurs dernières commandes, leur fréquence antérieure et leur valeur cumulée.
2. Confronter cette liste à l’historique de contacts et à la cadence normale d’achat (données CRM à obtenir).
3. Si une absence de commande inhabituelle est confirmée, tester une relance personnalisée sur un petit groupe, sans supposer l’effet causal de la relance.
4. Mesurer les retours et réexaminer la segmentation après la période d’observation retenue.

**Indicateurs de suivi :** part des dix comptes qualifiés, taux de contact, taux de réponse, part ayant passé une nouvelle commande, montant des achats suivant la relance. Pour estimer un effet incrémental, prévoir un groupe comparable non relancé lorsque cela est possible.

**Limites :** l’historique est fictif et ancien ; la récence est relative à la dernière date de commande enregistrée. Le projet ne contient pas de données permettant d’observer une réactivation effectivement menée.

**Preuves à consulter :** `SQL/03_customer_analysis.sql`, `dbo.v_bi_customer_360` et page **Customer Analysis** du dashboard.

## 2. Produits : séparer performance en valeur et demande en unités

### Constat étayé

Les catégories **Beverages** (environ **267,9 k$**) et **Dairy Products** (environ **234,5 k$**) représentent ensemble **environ 40 % du chiffre d’affaires net** d’environ **1 265,8 k$**, sur la base des montants de présentation arrondis. **Côte de Blaye** mène le classement du CA net produit (environ **141,4 k$**), tandis que **Camembert Pierrot** mène celui des unités vendues (environ **1,6 k unités**).

### Hypothèse et recommandation

Un classement par CA ne répond pas au même besoin qu’un classement par unités. Il convient de **conserver deux angles de pilotage**, plutôt que de décréter qu’un produit vendu en volume est aussi celui à prioriser en valeur ou en marge.

**Plan d’action proposé :**

1. Identifier les références majeures selon **CA net**, **unités vendues** et **nombre de commandes distinctes**.
2. Comparer leur évolution mensuelle en excluant le mois **mai 1998**, incomplet pour l’analyse de tendance.
3. Croiser cette demande avec les délais de réapprovisionnement, les disponibilités et la marge réelle **si ces données deviennent disponibles**.
4. Réexaminer les règles d’assortiment et de commande après cette mise en perspective.

**Indicateurs de suivi :** parts du CA par catégorie, unités et pénétration de commandes par produit, évolution mensuelle ; puis taux de rupture, délai fournisseur, rotation et marge **uniquement avec de nouvelles données**.

**Limites :** `Products.UnitsInStock` est un **instantané** de stock, pas une série historique ; le CA ne représente pas une marge. Une variation mensuelle observée sur moins de deux années complètes ne suffit pas à établir une saisonnalité récurrente.

**Preuves à consulter :** `SQL/04_product_analysis.sql`, `dbo.v_bi_product_performance_by_region` et page **Product Performance**.

## 3. Logistique : identifier les écarts avant d’attribuer des causes

### Constat étayé

Sur le périmètre éligible du dashboard, le délai moyen **commande → expédition** est d’environ **8,49 jours**, et le taux de **`ShippedDate > RequiredDate`** d’environ **4,57 %**. Le tableau de bord présente, pour **Federal Shipping**, **7,47 jours** et **3,61 %**, contre **9,23 jours** et **5,08 %** pour **United Package**.

### Hypothèse et recommandation

Ces différences justifient une **revue du processus de préparation et d’expédition**, mais ne démontrent pas qu’un transporteur est responsable des retards. Les affectations peuvent varier selon les pays, les volumes et les profils de commandes.

**Plan d’action proposé :**

1. Comparer les **effectifs** et la distribution des délais par transporteur, pays et mois.
2. Analyser les commandes expédiées après la date requise, puis les cas avec date requise manquante.
3. Investiguer séparément les temps de préparation interne, les contraintes de destination et les règles d’affectation des transporteurs (informations opérationnelles à obtenir).
4. Proposer une modification de processus **seulement après** une comparaison à périmètre comparable.

**Indicateurs de suivi :** délai médian et moyen commande → expédition, taux d’expédition après date requise, répartition et effectifs par transporteur/destination, proportion de dates requises manquantes.

**Limites :** `ShippedDate` **n’est pas la date de livraison au client** ; `Freight` est le montant enregistré dans Northwind, sans preuve qu’il représente le coût économique complet du transport. Les moyennes par transporteur ne sont pas causalement interprétables seules.

**Preuves à consulter :** `SQL/05_logistics_analysis.sql`, `dbo.v_bi_shipping_performance` et page **Logistics & Shipping**.

## Points d’arbitrage et vérifications avant décision

- **Ne pas confondre résultats, hypothèses et impact mesuré.** Toutes les actions sont des propositions ; aucun effet commercial ou logistique n’a été observé après intervention.
- **Ne pas surinterpréter les comparaisons.** La valeur client, les volumes produits et les délais peuvent dépendre de dimensions absentes du jeu de données.
- **Documenter le périmètre des KPI.** CA net calculé sur les prix des lignes de commande et remises ; récence RFM relative à la date maximale des commandes ; taux d’expédition tardive limité aux commandes éligibles.
- **Contrôler les rafraîchissements CSV.** Le dashboard utilise des exports importés et non une connexion SQL Server en temps réel.

## Comment défendre ces recommandations en entretien de conseil

> « Je présente d’abord trois faits contrôlables dans les analyses SQL. Pour chacun, je propose une action que l’entreprise **pourrait tester**, les données complémentaires à collecter, un indicateur de suivi et les limites de l’interprétation. Je ne présente pas ces recommandations comme des gains déjà obtenus. »

**Sources internes :** README principal, `SQL/03_customer_analysis.sql`, `SQL/04_product_analysis.sql`, `SQL/05_logistics_analysis.sql`, `SQL/07_kpi_views.sql` et les cinq pages du dashboard.
