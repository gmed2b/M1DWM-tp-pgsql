CREATE TABLE personnes (
  id_personne SERIAL PRIMARY KEY,
  prenom VARCHAR(255) NOT NULL,
  nom VARCHAR(255) NOT NULL,
  date_naissance DATE NOT NULL,
  email VARCHAR(50) UNIQUE,
  telephone VARCHAR(15) UNIQUE,
  adresse TEXT
);

CREATE TABLE enseignants (
  numero_enseignant SERIAL PRIMARY KEY,
  id_personne INT NOT NULL,
  specialite VARCHAR(50) NOT NULL,
  departement VARCHAR(50) NOT NULL,
  FOREIGN KEY (id_personne)
  REFERENCES personnes(id_personnes)
);

CREATE TABLE etudiants (
  numero_etudiant SERIAL PRIMARY KEY,
  id_personne INT NOT NULL,
  email_etudiant VARCHAR(50) NOT NULL,
  FOREIGN KEY (id_personne)
  REFERENCES personnes(id_personnes)
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
  niveau VARCHAR(255) NOT NULL,
  nbr_max_etu INT NOT NULL,
  CHECK (nbr_max_etu >= 1),
  FOREIGN KEY (id_formation)
  REFERENCES formations(id_formation)
);

CREATE TABLE semestres (
  id_semestre SERIAL PRIMARY KEY,
  id_annee_formation INT NOT NULL,
  nom VARCHAR(255) NOT NULL,
  date_debut DATE NOT NULL,
  date_fin DATE NOT NULL,
  CHECK (date_fin > date_debut),
  FOREIGN KEY (id_annee_formation)
  REFERENCES annees_formation(id_annee_formation)
);

CREATE TABLE unites_enseignement(
  id_ue SERIAL PRIMARY KEY,
  id_semestre INT NOT NULL,
  nom VARCHAR(255) NOT NULL,
  coefficient NUMERIC(2,1),
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
    valide_le TIMESTAMP,
    FOREIGN KEY (numero_etudiant)
    REFERENCES etudiants(numero_etudiant),
    FOREIGN KEY (id_annee_formation)
    REFERENCES annees_formation(id_annee_formation)
);

CREATE TABLE notes_ec (
    id_inscription INT NOT NULL,
    id_ec INT NOT NULL,
    note NUMERIC(3, 1) NOT NULL,
    CHECK (note > 0),
    PRIMARY KEY (id_inscription, id_ec)
);

CREATE OR REPLACE FUNCTION verification_inscription()
RETURNS TRIGGER AS $$
  BEGIN
    -- Recherche du nombre d'etudiant inscrit
    SELECT COUNT(1)

  END
$$ LANGUAGE plpgsql;