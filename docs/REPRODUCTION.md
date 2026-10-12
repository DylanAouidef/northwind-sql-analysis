# Reproduire le projet Northwind — SQL Server / DBeaver / Looker Studio

**Statut au 12 octobre 2026 :** les tables, six vues SQL et contrôles de chiffre d'affaires ont été testés dans l'environnement du projet ; le rapport Looker Studio a été nettoyé pour conserver **six sources CSV**. Une réinstallation intégrale **sur une autre instance** et une reconstruction à l'identique du dashboard n'ont **pas encore** été testées de bout en bout.

> **Sécurité :** le script officiel Microsoft `instnwnd.sql` contient des `DROP TABLE` / `DROP VIEW` et d'autres instructions de remplacement. **NE PAS le relancer** dans `master`, ni dans la base `Northwind` actuellement utilisée, ni dans une base comportant des données à conserver. La procédure d'installation ci-dessous concerne **uniquement une instance de test avec base vide**. Aucun script de ce dépôt ne supprime les tables de `master`.

## 1. Pré-requis

- Une instance Microsoft SQL Server accessible en local ou sur serveur de test, avec les droits nécessaires pour créer une base et des objets.
- Un client SQL : DBeaver (utilisé dans le projet), ou `sqlcmd` pour l'installation initiale officielle contenant des séparateurs `GO`.
- Le script officiel Microsoft [`instnwnd.sql`](https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/northwind-pubs/instnwnd.sql) ; **non inclus** dans ce dépôt.
- Les fichiers du dépôt `SQL/01_...sql` à `SQL/07_kpi_views.sql`.
- Pour la BI : accès à Looker Studio et, si besoin, Google Sheets pour importer les exports CSV.

Le nombre exact de versions SQL Server / DBeaver compatibles n'a pas fait l'objet d'une matrice de tests. Conserver les informations de version exécutées localement (`SELECT @@VERSION;`) lors d'une nouvelle reproduction.

## 2. Deux parcours possibles

### Parcours A — Analyser la base `Northwind` déjà en place

**C'est le parcours pour l'environnement actuellement utilisé.** Ne pas exécuter `instnwnd.sql` ; les 13 tables et leurs données sont déjà dans `Northwind`.

Dans DBeaver, sur `SQLServer_Localhost` :

```sql
SELECT DB_NAME() AS BaseActuelle;
SELECT COUNT(*) AS NombreCommandes FROM Northwind.dbo.Orders;
SELECT COUNT(*) AS NombreLignesCommande FROM Northwind.dbo.[Order Details];
SELECT @@VERSION AS VersionSqlServer;
```

Les deux nombres observés lors des tests sont **830** et **2 155**. Les fichiers du projet commencent par `USE [Northwind];`, même si la barre DBeaver montre encore `dbo@master` avant leur exécution. Lancer **le script complet**, et non une sélection, afin d'appliquer le changement de contexte. Uniquement pour les scripts d'analyse, éviter d'interroger `master` par erreur.

Passer directement à l'étape 3.

### Parcours B — Recréer l'installation depuis zéro (autre instance, base vide)

**Ne pas réaliser ce parcours sur le SQL Server contenant les données du projet actuel.**

1. Télécharger `instnwnd.sql` depuis le dépôt officiel Microsoft. Ce fichier ne crée pas la base de données : il crée les objets dans la base active, généralement sous le schéma `dbo`. Il comporte aussi des instructions de suppression d'objets préexistants.
2. Sur une **instance de test distincte**, se connecter à `master`, puis exécuter la commande ci-dessous **une seule fois**. Elle refuse de continuer si `Northwind` existe déjà :

```sql
IF DB_ID(N'Northwind') IS NOT NULL
    THROW 50001, N'Northwind existe déjà : interrompre pour éviter un écrasement.', 1;
EXEC(N'CREATE DATABASE [Northwind]');
```

3. Vérifier le contexte, puis que la base est vierge :

```sql
SELECT COUNT(*) AS TablesExistantes
FROM Northwind.sys.tables
WHERE is_ms_shipped = 0;
```

**Attendu : 0.** Si le résultat diffère, **s'arrêter**.

4. Installer les données dans la **base vierge**. Le fichier officiel contient `GO`, qui est un séparateur de lots interprété par des clients SQL, mais pas par le serveur lui-même. Pour éviter l'erreur `Incorrect syntax near 'GO'` observée lors de l'exécution d'une sélection dans DBeaver, utiliser de préférence `sqlcmd`, lorsqu'il est installé et configuré :

```bash
# Exemple à adapter : sur une instance SQL Server de TEST uniquement.
# Saisir le mot de passe si le client sqlcmd le demande ; ne pas le mettre dans la commande.
sqlcmd -S localhost,1433 -U sa -d Northwind -b -i "$HOME/Downloads/instnwnd.sql"
```

La syntaxe et les options TLS peuvent varier selon la version de `sqlcmd` et la configuration du serveur. Si `sqlcmd` n'est pas installé, utiliser un outil qui prend en charge les lots `GO`, avec `Northwind` comme base active. Dans DBeaver, il faut exécuter le **script complet avec un séparateur de lot `GO` reconnu** : ne jamais envoyer les lignes `GO` directement au serveur comme une instruction SQL ordinaire.

5. Revenir dans DBeaver et contrôler les **13 tables**, dont `Orders` (830) et `[Order Details]` (2 155). Si les nombres diffèrent, vérifier la version du script et les éventuelles erreurs du chargement avant toute analyse.

**Ne pas utiliser les scripts de migration `master → Northwind` de l'environnement historique** pour cette réinstallation : ils copient depuis une ancienne base `master` et ne constituent pas le chemin normal de reproduction d'un nouveau projet.

## 3. Exécuter les sept scripts d'analyse

Dans DBeaver, connecter l'éditeur à la base `Northwind` et exécuter les scripts **un à un, dans cet ordre** :

| Ordre | Fichier | Rôle | Modifie les données ? |
|---|---|---|---|
| 1 | `SQL/01_data_cleaning.sql` | Audit des données et des anomalies | Non |
| 2 | `SQL/02_sales_analysis.sql` | Analyse des ventes et séries temporelles | Non |
| 3 | `SQL/03_customer_analysis.sql` | Analyse client et segmentation RFM | Non |
| 4 | `SQL/04_product_analysis.sql` | Produits, catégories et réconciliation du CA | Non |
| 5 | `SQL/05_logistics_analysis.sql` | Analyse expéditions et transporteurs | Non |
| 6 | `SQL/06_employee_analysis.sql` | Analyse de l'activité commerciale par employé | Non |
| 7 | `SQL/07_kpi_views.sql` | Création/mise à jour des **six vues BI** | **Oui, définitions des vues uniquement** |

Le nom `01_data_cleaning` est historique : il s'agit de contrôles de qualité, non d'un nettoyage qui modifierait les données. La version corrigée des sept scripts cible `USE [Northwind];` et ne nécessite pas `GO` pour ces sept scripts. Dans le script 07, `EXEC(N'...')` permet d'exécuter les déclarations de vues en lots compatibles avec JDBC/DBeaver.

## 4. Vérifier les résultats

1. Lancer **après le script 07** `SQL/09_controles_reproductibilite.sql` ; c'est un script en lecture seule.
2. Contrôler les nombres : **13 tables**, **830 commandes**, **2 155 lignes de commandes**, **91 clients**, **77 produits**, **six vues BI**, **13 clés étrangères** et **8 contraintes CHECK**.
3. Vérifier le chiffre d'affaires net défini par `SUM(Quantity × UnitPrice × (1 − Discount))` avec conversion de `Discount` en `DECIMAL(18,4)` : **1 265 793,0395 $** avant arrondi d'affichage, soit **1 265 793,04 $** à deux décimales.
4. Les six vues ont produit respectivement **21 / 830 / 2 038 / 809 / 89 / 9** lignes lors du test d'octobre 2026 (voir la sortie du script). Ces nombres peuvent varier avec la version des données ou l'évolution du SQL.

La présence des mêmes nombres de lignes seule n'établit **pas** une identité complète de contenu. Sur l'environnement historique, un contrôle d'ensembles de lignes et de contraintes a également été réalisé. Pour un audit approfondi dans une nouvelle instance, ajouter les comparaisons de contenu, de schéma et d'intégrité appropriées.

## 5. Alimenter Looker Studio

1. Après avoir créé les vues, exécuter `SQL/10_exports_looker_studio.sql`.
2. Dans DBeaver, pour chacun des **six jeux de résultats** : clic droit sur les résultats → **Export Data**, puis enregistrer en CSV UTF-8 avec en-tête (ou exporter directement une vue via DBeaver). Conserver séparément chaque vue, sans arrondir les mesures dans l'export.
3. Importer les six CSV dans le connecteur choisi. Option de reproduction : un onglet Google Sheets par vue, puis créer six sources Looker Studio. Cette procédure est une **proposition de reproduction**, pas une preuve du connecteur exact historiquement utilisé.
4. Relier les sources aux cinq pages du rapport (cf. [MAPPING_LOOKER_STUDIO.md](MAPPING_LOOKER_STUDIO.md)). Vérifier que les champs numériques restent numériques, que les dates sont reconnues comme dates et que la virgule décimale ne devient pas du texte.
5. Comparer les KPI et filtres du dashboard reconstruit avec les captures `screenshots/`. La capture `screenshots/page2_products.png` reflète le nouveau graphique mensuel en colonnes empilées classiques (et non 100 % empilées). Le **design exact et les champs calculés côté Looker Studio** ne peuvent pas être reconstruits à l'identique à partir des captures seules : un accès à la configuration source ou des exports détaillés sont nécessaires.

## 6. Ce qu'il reste à attester pour une reproduction intégrale

- Version exacte de SQL Server et version du client : non enregistrées dans les fichiers du dépôt ; commande utile : `SELECT @@VERSION;`.
- Provenance originale du téléchargement : le fichier local est identique au script Microsoft au moment du contrôle, mais son historique de téléchargement n'a pas été prouvé.
- Six sources Looker Studio désormais identifiées dans le rapport ; leurs valeurs n'ont pas toutes été comparées exhaustivement avec les exports SQL. Les types, agrégations et filtres restent à vérifier pour une reproduction intégrale.
- Exécution complète dans une **deuxième instance vierge** : non réalisée à ce jour.

**Règle de publication :** documenter les manipulations réellement faites et leurs limites ; ne pas annoncer un « setup automatique testé de bout en bout » tant que cette exécution indépendante n'est pas faite.
