-- Tables
DROP TABLE IF EXISTS avis_etudiant_formation;
DROP TABLE IF EXISTS notes_ec;
DROP TABLE IF EXISTS inscriptions;
DROP TABLE IF EXISTS elements_constitutif;
DROP TABLE IF EXISTS unites_enseignement;
DROP TABLE IF EXISTS semestres;
DROP TABLE IF EXISTS annees_formation;
DROP TABLE IF EXISTS formations;
DROP TABLE IF EXISTS etudiants;
DROP TABLE IF EXISTS enseignants;
DROP TABLE IF EXISTS personnes;

CREATE TABLE personnes (
  id_personne SERIAL PRIMARY KEY,
  titre VARCHAR(10),
  prenom VARCHAR(255) NOT NULL,
  nom VARCHAR(255) NOT NULL,
  date_naissance DATE NOT NULL,
  email VARCHAR(60) UNIQUE,
  telephone VARCHAR(30) UNIQUE,
  adresse TEXT
);

CREATE TABLE enseignants (
  numero_enseignant SERIAL PRIMARY KEY,
  id_personne INT NOT NULL,
  specialite VARCHAR(50) NOT NULL,
  departement VARCHAR(50) NOT NULL,
  FOREIGN KEY (id_personne)
  REFERENCES personnes(id_personne)
);

CREATE TABLE etudiants (
  numero_etudiant SERIAL PRIMARY KEY,
  id_personne INT NOT NULL,
  email_etudiant VARCHAR(50) NOT NULL,
  FOREIGN KEY (id_personne)
  REFERENCES personnes(id_personne)
);

CREATE TABLE formations (
  id_formation SERIAL PRIMARY KEY,
  nom VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  niveau VARCHAR(255) NOT NULL,
  departement VARCHAR(255) NOT NULL
);

CREATE TABLE annees_formation(
  id_annee_formation SERIAL PRIMARY KEY,
  id_formation INT NOT NULL,
  date_formation DATE NOT NULL,
  niveau VARCHAR(255) NOT NULL,
  nbr_max_etu INT NOT NULL,
  CHECK (nbr_max_etu >= 1),
  FOREIGN KEY (id_formation)
  REFERENCES formations(id_formation)
);

CREATE TABLE semestres (
  id_semestre SERIAL PRIMARY KEY,
  id_annee_formation INT NOT NULL,
  semestre VARCHAR(255) NOT NULL,
  date_debut DATE NOT NULL,
  date_fin DATE NOT NULL,
  CHECK (date_fin > date_debut),
  FOREIGN KEY (id_annee_formation)
  REFERENCES annees_formation(id_annee_formation),
  UNIQUE (id_annee_formation, semestre)
);

CREATE TABLE unites_enseignement(
  id_ue SERIAL PRIMARY KEY,
  id_semestre INT NOT NULL,
  nom VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  coefficient NUMERIC(2,1),
  obligatoire BOOLEAN NOT NULL,
  CHECK (coefficient > 0),
  FOREIGN KEY (id_semestre)
  REFERENCES semestres(id_semestre)
);

CREATE TABLE elements_constitutif(
  id_ec SERIAL PRIMARY KEY,
  id_ue INT NOT NULL,
  numero_enseignant INT NOT NULL,
  nom VARCHAR(255),
  heures_cours INT,
  heures_td INT,
  heures_tp INT,
  modalites_evaluation TEXT,
  FOREIGN KEY (id_ue)
  REFERENCES unites_enseignement(id_ue),
  FOREIGN KEY (numero_enseignant)
  REFERENCES enseignants(numero_enseignant)
);

CREATE TABLE inscriptions (
    id_inscription SERIAL PRIMARY KEY,
    numero_etudiant INT NOT NULL,
    id_annee_formation INT NOT NULL,
    date_inscription DATE NOT NULL DEFAULT CURRENT_DATE,
    valide_le TIMESTAMP,
    mention VARCHAR(255),
    FOREIGN KEY (numero_etudiant)
    REFERENCES etudiants(numero_etudiant),
    FOREIGN KEY (id_annee_formation)
    REFERENCES annees_formation(id_annee_formation),
    UNIQUE (numero_etudiant, id_annee_formation)
);

CREATE TABLE notes_ec (
    id_inscription INT NOT NULL,
    id_ec INT NOT NULL,
    note NUMERIC(3, 1) NOT NULL,
    CHECK (note >= 0 AND note <= 20),
    PRIMARY KEY (id_inscription, id_ec)
);

CREATE TABLE avis_etudiant_formation (
  id_formation INT NOT NULL,
  numero_etudiant INT NOT NULL,
  avis TEXT NOT NULL,
  PRIMARY KEY (id_formation, numero_etudiant),
  FOREIGN KEY (id_formation)
  REFERENCES formations(id_formation),
  FOREIGN KEY (numero_etudiant)
  REFERENCES etudiants(numero_etudiant)
);


-- Triggers

CREATE OR REPLACE FUNCTION verification_inscription()
RETURNS TRIGGER AS $$
  DECLARE
    _nbr_etudiant INT;
    _nbr_max_etu INT;
  BEGIN
    -- Recherche du nombre d'etudiants déjà inscrits à la formation
    SELECT COUNT(1) INTO _nbr_etudiant
    FROM inscriptions
    WHERE id_annee_formation = NEW.id_annee_formation;

    -- Recherche du nombre maximum d'etudiants pour la formation
    SELECT nbr_max_etu INTO _nbr_max_etu
    FROM annees_formation
    WHERE id_annee_formation = NEW.id_annee_formation;

    -- Si le nombre d'etudiants inscrits est superieur au nombre maximum autorisé
    IF _nbr_etudiant >= _nbr_max_etu THEN
      RAISE EXCEPTION 'Le nombre maximum d''etudiants pour cette formation est atteint';
    END IF;

    RETURN NEW;
  END
$$ LANGUAGE plpgsql;

CREATE TRIGGER verification_inscription
BEFORE INSERT OR UPDATE ON inscriptions
FOR EACH ROW EXECUTE FUNCTION verification_inscription();