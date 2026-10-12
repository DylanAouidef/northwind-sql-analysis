# Origine et traçabilité des données — Northwind

## Ce qui est établi

- **Jeu de données** : Northwind, démonstration relationnelle historique de Microsoft pour SQL Server.
- **Source officielle de référence** : [microsoft/sql-server-samples — northwind-pubs](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs).
- **Fichier source officiel** : [`instnwnd.sql`](https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/northwind-pubs/instnwnd.sql).
- **Vérification réalisée le 11 octobre 2026** : l'empreinte SHA-256 du `instnwnd.sql` conservé localement correspondait à l'empreinte de la version téléchargée depuis le dépôt Microsoft au moment du contrôle (captures de vérification dans l'historique de préparation, non ajoutées au dépôt).
- **SGBD d'analyse** : Microsoft SQL Server ; tables dans le schéma `dbo`, base dédiée `Northwind`.
- **Structure utilisée** : 13 tables relationnelles ; notamment 830 commandes, 91 clients, 77 produits, 2 155 lignes de détail de commandes, constatés dans l'environnement de travail.

## Ce qui n'est pas démontré

- Nous ne disposons pas de la preuve irréfutable que le fichier `instnwnd.sql` retrouvé est **celui qui a été exécuté historiquement** lors de la première installation.
- L'URL de téléchargement initiale du fichier local n'a pas pu être déterminée : macOS renvoyait `kMDItemWhereFroms = (null)`.
- Un autre fichier `northwind.sql` retrouvé sur le Mac est un script **MySQL** ; il ne constitue pas le script d'installation SQL Server documenté ici.

L'ancien environnement plaçait les tables Northwind dans `master`. Le 11 octobre 2026, elles ont été copiées dans une base dédiée `Northwind`, avec vérifications des nombres de lignes, de leur contenu et des contraintes. Les tables de `master` n'ont pas été supprimées. Ce processus historique est distinct de la **recréation propre sur une instance vierge** décrite dans [REPRODUCTION.md](REPRODUCTION.md).

## Refaire une comparaison d'empreinte sur macOS

```bash
shasum -a 256 "$HOME/Downloads/instnwnd.sql"
curl -fsSL "https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/databases/northwind-pubs/instnwnd.sql" | shasum -a 256
```

Ces commandes ne modifient aucune base SQL Server. Les empreintes peuvent différer à l'avenir si Microsoft modifie la branche `master` ; une égalité de hash confirme seulement l'identité *octet pour octet* de deux fichiers comparés à l'instant considéré.

## Politique de publication

Le script d'installation Microsoft **n'est pas recopié dans ce dépôt**. Les utilisateurs récupèrent la version officielle eux-mêmes et respectent sa licence. Aucun mot de passe, chaîne de connexion privée, export client confidentiel ni sauvegarde serveur n'est publié.
