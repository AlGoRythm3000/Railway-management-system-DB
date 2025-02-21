-- 1. Tables indépendantes en premier
\copy "Train" (nb_places,compagnie) FROM '/var/lib/postgresql/railway_data/railway/csv/trains.csv' WITH CSV HEADER;

\copy "Station" (nom,ville,pays,localisation) FROM '/var/lib/postgresql/railway_data/railway/csv/stations.csv' WITH CSV HEADER;

-- utilisateur doit être importé avant Personnel et Passager
\copy "Utilisateur" (mail,nom,prenom,age) FROM '/var/lib/postgresql/railway_data/railway/csv/utilisateurs.csv' WITH CSV HEADER;

-- Personnel et Passager qui dépendent d'Utilisateur
\copy "Personnel" (mail_personnel,role) FROM '/var/lib/postgresql/railway_data/railway/csv/personnel.csv' WITH CSV HEADER;

\copy "Passager" (mail_passager,abonnement) FROM '/var/lib/postgresql/railway_data/railway/csv/passagers.csv' WITH CSV HEADER;

-- Trajet dépend de Station
\copy "Trajet" (station_depart,station_arrivee,date_depart,prix_total) FROM '/var/lib/postgresql/railway_data/railway/csv/trajets.csv' WITH CSV HEADER;

-- Troncon dépend de Trajet, Train et Station
\copy "Troncon" (id_trajet,train_id,station_depart,station_arrivee,heure_depart,heure_arrivee,ordre,prix) FROM '/var/lib/postgresql/railway_data/railway/csv/troncons.csv' WITH CSV HEADER;

-- Reservation qui dépend de Passager et Trajet
\copy "Reservation" (mail_passager,id_trajet,date_reservation,statut) FROM '/var/lib/postgresql/railway_data/railway/csv/reservations.csv' WITH CSV HEADER;

-- Place qui dépend de Reservation et Troncon
\copy "Place" (id_reservation,id_troncon,numero_place,classe) FROM '/var/lib/postgresql/railway_data/railway/csv/places.csv' WITH CSV HEADER;

-- Assignation_Personnel qui dépend de Personnel et Troncon
\copy "Assignation_Personnel" (mail_personnel,id_troncon) FROM '/var/lib/postgresql/railway_data/railway/csv/assignations_personnel.csv' WITH CSV HEADER;
