-- create_tables.sql
-- Vérifie si les tables existent déjà
DO $$ 
BEGIN
            -- Suppression des tables existantes
        DROP TABLE IF EXISTS "Assignation_Personnel" CASCADE;
        DROP TABLE IF EXISTS "Place" CASCADE;
        DROP TABLE IF EXISTS "Reservation" CASCADE;
        DROP TABLE IF EXISTS "Troncon" CASCADE;
        DROP TABLE IF EXISTS "Trajet" CASCADE;
        DROP TABLE IF EXISTS "Passager" CASCADE;
        DROP TABLE IF EXISTS "Personnel" CASCADE;
        DROP TABLE IF EXISTS "Utilisateur" CASCADE;
        DROP TABLE IF EXISTS "Station" CASCADE;
        DROP TABLE IF EXISTS "Train" CASCADE;

        -- Table Train
        CREATE TABLE "Train" (
            "numero" SERIAL PRIMARY KEY,
            "nb_places" INTEGER NOT NULL,
            "compagnie" VARCHAR(255) NOT NULL
        );

        -- Table Station
        CREATE TABLE "Station" (
            "id" SERIAL PRIMARY KEY,
            "nom" VARCHAR(255) NOT NULL,
            "ville" VARCHAR(255) NOT NULL,
            "pays" VARCHAR(255) NOT NULL,
            "localisation" POINT NOT NULL,
            UNIQUE("nom", "ville")
        );

        -- Table Utilisateur
        CREATE TABLE "Utilisateur" (
            "mail" VARCHAR(255) PRIMARY KEY,
            "nom" VARCHAR(255) NOT NULL,
            "prenom" VARCHAR(255) NOT NULL,
            "age" INTEGER NOT NULL
        );

        -- Table Personnel
        CREATE TABLE "Personnel" (
            "mail_personnel" VARCHAR(255) PRIMARY KEY,
            "role" VARCHAR(255) NOT NULL,
            FOREIGN KEY ("mail_personnel") REFERENCES "Utilisateur"("mail")
        );

        -- Table Passager (hérite d'Utilisateur)
	CREATE TABLE "Passager" (
    	    "mail_passager" VARCHAR(255) PRIMARY KEY,
    	    "abonnement" BOOLEAN NOT NULL DEFAULT FALSE,
    	FOREIGN KEY ("mail_passager") REFERENCES "Utilisateur"("mail")
	);

	-- Table Trajet (représente l'itinéraire complet)
	CREATE TABLE "Trajet" (
    	    "id" SERIAL PRIMARY KEY,
    	    "station_depart" INTEGER NOT NULL,
    	    "station_arrivee" INTEGER NOT NULL,
            "date_depart" DATE NOT NULL,
            "prix_total" DECIMAL(10,2) NOT NULL,
    	    FOREIGN KEY ("station_depart") REFERENCES "Station"("id"),
	    FOREIGN KEY ("station_arrivee") REFERENCES "Station"("id"),
            CONSTRAINT check_stations CHECK ("station_depart" != "station_arrivee")
	);

	CREATE TABLE "Troncon" (
	    "id" SERIAL PRIMARY KEY,
    	    "id_trajet" INTEGER NOT NULL,
    	    "train_id" INTEGER NOT NULL,
    	    "station_depart" INTEGER NOT NULL,
    	    "station_arrivee" INTEGER NOT NULL,
    	    "heure_depart" TIMESTAMP NOT NULL,
    	    "heure_arrivee" TIMESTAMP NOT NULL,
    	    "ordre" INTEGER NOT NULL, -- Pour ordonner les tronçons dans un trajet
    	    "prix" DECIMAL(10,2) NOT NULL,
    	    FOREIGN KEY ("id_trajet") REFERENCES "Trajet"("id"),
    	    FOREIGN KEY ("train_id") REFERENCES "Train"("numero"),
    	    FOREIGN KEY ("station_depart") REFERENCES "Station"("id"),
    	    FOREIGN KEY ("station_arrivee") REFERENCES "Station"("id"),
    	    CONSTRAINT check_troncon_stations CHECK ("station_depart" != "station_arrivee"),
    	    CONSTRAINT check_troncon_heures CHECK ("heure_arrivee" > "heure_depart")
);
	-- Table Reservation
CREATE TABLE "Reservation" (
    "id" SERIAL PRIMARY KEY,
    "mail_passager" VARCHAR(255) NOT NULL,
    "id_trajet" INTEGER NOT NULL,
    "date_reservation" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "statut" VARCHAR(50) DEFAULT 'confirmé',
    FOREIGN KEY ("mail_passager") REFERENCES "Passager"("mail_passager"),
    FOREIGN KEY ("id_trajet") REFERENCES "Trajet"("id")
);

-- Table Place (une place par tronçon dans la réservation)
    CREATE TABLE "Place" (
    	"id" SERIAL PRIMARY KEY,
    	"id_reservation" INTEGER NOT NULL,
    	"id_troncon" INTEGER NOT NULL,
    	"numero_place" VARCHAR(10) NOT NULL,
    	"classe" INTEGER NOT NULL,
    	FOREIGN KEY ("id_reservation") REFERENCES "Reservation"("id"),
    	FOREIGN KEY ("id_troncon") REFERENCES "Troncon"("id")
	);

	-- Table Assignation_Personnel
	CREATE TABLE "Assignation_Personnel" (
    	"mail_personnel" VARCHAR(255),
    	"id_troncon" INTEGER,
    	PRIMARY KEY ("mail_personnel", "id_troncon"),
    	FOREIGN KEY ("mail_personnel") REFERENCES "Personnel"("mail_personnel"),
    	FOREIGN KEY ("id_troncon") REFERENCES "Troncon"("id")
	);

        -- Création des index
        CREATE INDEX idx_troncon_dates ON "Troncon"("heure_depart", "heure_arrivee");
        CREATE INDEX idx_station_nom ON "Station"("nom", "ville");
        CREATE INDEX idx_trajet_dates ON "Trajet"("date_depart");

        RAISE NOTICE 'Tables créées avec succès';
END $$;
