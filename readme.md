# Railway Management System

## Description

Le projet *Railway Management System* est une application de gestion ferroviaire développée en Java et utilisant PostgreSQL comme base de données. Il permet de gérer les trajets, les passagers, le personnel et les réservations.

## Structure du Projet

```
/railway
│
├── /csv                           # Fichiers de données
│   ├── trains.csv
│   ├── stations.csv
│   ├── utilisateurs.csv
│   ├── personnel.csv
│   ├── passagers.csv
│   ├── trajets.csv
│   ├── troncons.csv
│   ├── reservations.csv
│   ├── places.csv
│   └── assignations_personnel.csv
│
├── /sql                          # Scripts SQL
│   ├── create_tables.sql        # Création des tables
│   ├── import_csv.sql          # Import des données
│   └── reset_sequences.sql     # Réinitialisation des séquences
│
├── /java                         # Application Java
│   ├── src/
│   │   └── main/
│   │       └── java/
│   │           └── com/
│   │               └── railway/
│   │                   ├── DatabaseConnection.java
│   │                   └── MainApp.java
│   └── pom.xml
│
└── README.md
```

---

## Configuration de la Base de Données

### Création de la Base de Données

```bash
# Se connecter en tant que postgres
sudo -u postgres psql

# Dans psql
CREATE DATABASE railway;
\q

# Vérifier la création
psql -l
```

### Configuration de l'Utilisateur PostgreSQL

```bash
# Se connecter en tant que postgres
sudo -u postgres psql

# Créer un nouvel utilisateur
CREATE USER mon_utilisateur WITH PASSWORD 'mon_mot_de_passe';

# Donner les droits sur la base railway
GRANT ALL PRIVILEGES ON DATABASE railway TO mon_utilisateur;

# Modifier le mot de passe pour postgres
ALTER USER postgres PASSWORD 'votre_mot_de_passe';

\q
```

### Connexion à la Base de Données

```bash
# En tant que postgres
sudo -u postgres psql -d railway

# En tant qu'utilisateur normal
psql -d railway

# Avec mot de passe spécifique
psql -d railway -U mon_utilisateur -W
```

### Commandes PostgreSQL Utiles

```sql
\dt                      -- Liste des tables
\d nom_table            -- Structure d'une table
\df                     -- Liste des fonctions
\du                     -- Liste des utilisateurs
\l                      -- Liste des bases de données
\c nom_base            -- Se connecter à une base
\timing                -- Activer/désactiver le temps d'exécution
\x                     -- Activer/désactiver l'affichage étendu
\q                     -- Quitter psql
```

---

## Initialisation des Données

### Créer les tables

```bash
sudo -u postgres psql -d railway -f /chemin/vers/railway/sql/create_tables.sql
```

### Réinitialiser les séquences

```bash
sudo -u postgres psql -d railway -f /chemin/vers/railway/sql/reset_sequences.sql
```

### Importer les données

```bash
sudo -u postgres psql -d railway -f /chemin/vers/railway/sql/import_csv.sql
```

---

## Configuration de l'Application Java

### Configuration de la Connexion

Dans `DatabaseConnection.java` :

```java
private static final String URL = "jdbc:postgresql://localhost:5432/railway";
private static final String USER = "postgres";  // ou votre utilisateur
private static final String PASSWORD = "votre_mot_de_passe";
```

### Compilation et Exécution

```bash
# Se placer dans le dossier java
cd /chemin/vers/railway/java

# Compiler avec Maven
mvn clean package

# Exécuter l'application
java -jar target/railway-management-1.0-SNAPSHOT-jar-with-dependencies.jar
```

---

## Fonctionnalités de l'Application

L'interface graphique permet de :

- Visualiser les trajets
- Consulter la liste des passagers
- Voir le personnel par tronçon
- Afficher les statistiques de réservation

---

## Requêtes SQL Utiles

### Trajets d'un passager

```sql
SELECT t.id_trajet, s1.ville as depart, s2.ville as arrivee,
       t.heure_depart, t.heure_arrivee, t.prix
FROM "Troncon" t
JOIN "Station" s1 ON t.station_depart = s1.id
JOIN "Station" s2 ON t.station_arrivee = s2.id
JOIN "Reservation" r ON r.id_trajet = t.id_trajet
WHERE r.mail_passager = 'email@example.com';
```

### Statistiques des réservations

```sql
SELECT COUNT(*) as total_reservations,
       AVG(prix_total) as prix_moyen
FROM "Trajet" t
JOIN "Reservation" r ON t.id = r.id_trajet;
```

---

## Résolution des Problèmes Courants

### 1. Erreur d'authentification PostgreSQL

- Vérifier le mot de passe dans `DatabaseConnection.java`
- Vérifier les permissions dans `pg_hba.conf`
- Redémarrer PostgreSQL si nécessaire

### 2. Erreur de compilation Maven

- Vérifier la version de Java
- Nettoyer le projet : `mvn clean`
- Vérifier les dépendances dans `pom.xml`

### 3. Erreur d'exécution du JAR

- Vérifier que toutes les dépendances sont incluses
- Utiliser le JAR avec dépendances
- Vérifier les droits d'exécution

---

## Maintenance

### Sauvegardes

```bash
# Sauvegarder la base
gpg_dump -U postgres railway > backup.sql

# Restaurer la base
psql -U postgres railway < backup.sql
```

### Nettoyage

```sql
-- Vider toutes les tables
TRUNCATE TABLE "Assignation_Personnel", "Place", "Reservation",
"Troncon", "Trajet", "Passager", "Personnel", "Utilisateur",
"Station", "Train" CASCADE;
```

### Logs PostgreSQL

Les logs PostgreSQL se trouvent généralement dans :

```bash
/var/log/postgresql/postgresql-14-main.log
```

---
