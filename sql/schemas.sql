-- Suppression des tables si elles existent déjà, pour éviter les conflits
DROP TABLE IF EXISTS avis_etudiant_formation;
DROP TABLE IF EXISTS notes_ec;
DROP TABLE IF EXISTS resultats;
DROP TABLE IF EXISTS inscriptions;
DROP TABLE IF EXISTS elements_constitutif;
DROP TABLE IF EXISTS unites_enseignement;
DROP TABLE IF EXISTS semestres;
DROP TABLE IF EXISTS annees_formation;
DROP TABLE IF EXISTS formations;
DROP TABLE IF EXISTS etudiants;
DROP TABLE IF EXISTS enseignants;
DROP TABLE IF EXISTS personnes;

-- Table des personnes : contient les informations générales sur les individus (étudiants et enseignants)
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

-- Table des enseignants : chaque enseignant est lié à une personne et possède une spécialité et un département
CREATE TABLE enseignants (
  numero_enseignant SERIAL PRIMARY KEY,
  id_personne INT NOT NULL,
  specialite VARCHAR(50) NOT NULL,
  departement VARCHAR(50) NOT NULL,
  FOREIGN KEY (id_personne) REFERENCES personnes(id_personne)
);

-- Table des étudiants : chaque étudiant est lié à une personne et possède un email spécifique
CREATE TABLE etudiants (
  numero_etudiant SERIAL PRIMARY KEY,
  id_personne INT NOT NULL,
  email_etudiant VARCHAR(50) NOT NULL,
  FOREIGN KEY (id_personne) REFERENCES personnes(id_personne)
);

-- Table des formations : contient des informations sur les différentes formations offertes
CREATE TABLE formations (
  id_formation SERIAL PRIMARY KEY,
  nom VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  niveau VARCHAR(255) NOT NULL,
  departement VARCHAR(255) NOT NULL
);

-- Table des années de formation : chaque formation peut avoir plusieurs années d'études
CREATE TABLE annees_formation(
  id_annee_formation SERIAL PRIMARY KEY,
  id_formation INT NOT NULL,
  date_formation DATE NOT NULL,
  niveau VARCHAR(255) NOT NULL,
  nbr_max_etu INT NOT NULL CHECK (nbr_max_etu >= 1),
  FOREIGN KEY (id_formation) REFERENCES formations(id_formation)
);

-- Table des semestres : chaque année de formation est divisée en semestres
CREATE TABLE semestres (
  id_semestre SERIAL PRIMARY KEY,
  id_annee_formation INT NOT NULL,
  semestre VARCHAR(255) NOT NULL,
  date_debut DATE NOT NULL,
  date_fin DATE NOT NULL CHECK (date_fin > date_debut),
  FOREIGN KEY (id_annee_formation) REFERENCES annees_formation(id_annee_formation),
  UNIQUE (id_annee_formation, semestre)
);

-- Table des unités d'enseignement (UE) : chaque semestre peut avoir plusieurs UE
CREATE TABLE unites_enseignement(
  id_ue SERIAL PRIMARY KEY,
  id_semestre INT NOT NULL,
  nom VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  coefficient NUMERIC(2,1) CHECK (coefficient > 0),
  obligatoire BOOLEAN NOT NULL,
  FOREIGN KEY (id_semestre) REFERENCES semestres(id_semestre)
);

-- Table des éléments constitutifs (EC) : chaque UE est composée d'éléments constitutifs
CREATE TABLE elements_constitutif(
  id_ec SERIAL PRIMARY KEY,
  id_ue INT NOT NULL,
  numero_enseignant INT NOT NULL,
  nom VARCHAR(255),
  heures_cours INT,
  heures_td INT,
  heures_tp INT,
  modalites_evaluation TEXT,
  FOREIGN KEY (id_ue) REFERENCES unites_enseignement(id_ue),
  FOREIGN KEY (numero_enseignant) REFERENCES enseignants(numero_enseignant)
);

-- Table des inscriptions : enregistre les inscriptions des étudiants à une année de formation
CREATE TABLE inscriptions (
  id_inscription SERIAL PRIMARY KEY,
  numero_etudiant INT NOT NULL,
  id_annee_formation INT NOT NULL,
  date_inscription DATE NOT NULL DEFAULT CURRENT_DATE,
  valide_le TIMESTAMP,
  mention VARCHAR(255),
  FOREIGN KEY (numero_etudiant) REFERENCES etudiants(numero_etudiant),
  FOREIGN KEY (id_annee_formation) REFERENCES annees_formation(id_annee_formation),
  UNIQUE (numero_etudiant, id_annee_formation)
);

-- Table des notes pour chaque EC : enregistre les notes obtenues par les étudiants
CREATE TABLE notes_ec (
  id_inscription INT NOT NULL,
  id_ec INT NOT NULL,
  note NUMERIC(3, 1) NOT NULL CHECK (note >= 0 AND note <= 20),
  PRIMARY KEY (id_inscription, id_ec)
);

-- Table des résultats : stocke les moyennes calculées pour chaque semestre ou année
CREATE TABLE resultats (
  id_resultat SERIAL PRIMARY KEY,
  numero_etudiant INT NOT NULL,
  id_annee_formation INT NOT NULL,
  id_semestre INT NOT NULL,
  moyenne_semestre NUMERIC(4, 2),
  moyenne_annuelle NUMERIC(4, 2),
  mention VARCHAR(255),
  date_calcul TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (numero_etudiant) REFERENCES etudiants(numero_etudiant),
  FOREIGN KEY (id_annee_formation) REFERENCES annees_formation(id_annee_formation),
  FOREIGN KEY (id_semestre) REFERENCES semestres(id_semestre),
  UNIQUE (numero_etudiant, id_annee_formation, id_semestre)
);

-- Table des avis des étudiants sur les formations : chaque étudiant peut donner un avis sur une formation
CREATE TABLE avis_etudiant_formation (
  id_formation INT NOT NULL,
  numero_etudiant INT NOT NULL,
  avis TEXT NOT NULL,
  PRIMARY KEY (id_formation, numero_etudiant),
  FOREIGN KEY (id_formation) REFERENCES formations(id_formation),
  FOREIGN KEY (numero_etudiant) REFERENCES etudiants(numero_etudiant)
);
