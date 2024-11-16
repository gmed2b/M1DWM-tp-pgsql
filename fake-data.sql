-- Insérer des données dans la table personnes
INSERT INTO personnes (prenom, nom, date_naissance, email, telephone, adresse) VALUES
('Alice', 'Durand', '1990-05-14', 'alice.durand@example.com', '0601234567', '123 Rue de Paris, Paris'),
('Bob', 'Martin', '1988-02-20', 'bob.martin@example.com', '0607654321', '45 Avenue des Champs, Lyon'),
('Claire', 'Dupont', '1995-11-08', 'claire.dupont@example.com', '0612345678', '10 Rue de la République, Marseille'),
('David', 'Leclerc', '1980-07-22', 'david.leclerc@example.com', '0678451230', '9 Allée des Acacias, Toulouse'),
('Emma', 'Moreau', '1992-09-30', 'emma.moreau@example.com', '0623456789', '78 Boulevard Victor Hugo, Lille');

-- Insérer des données dans la table enseignants
-- Les enseignants sont liés à des personnes déjà insérées avec les id_personne correspondants
INSERT INTO enseignants (id_personne, specialite, departement) VALUES
(1, 'Informatique', 'Sciences'),
(2, 'Mathématiques', 'Mathématiques Appliquées');

-- Insérer des données dans la table étudiants
-- Les étudiants sont liés à des personnes déjà insérées avec les id_personne correspondants
INSERT INTO etudiants (id_personne, email_etudiant) VALUES
(3, 'claire.dupont@student.example.com'),
(4, 'david.leclerc@student.example.com'),
(5, 'emma.moreau@student.example.com');

-- Insérer des données dans la table formations
INSERT INTO formations (nom, description, niveau, departement) VALUES
('Licence Informatique', 'Formation en informatique couvrant programmation, bases de données, réseaux, etc.', 'Licence', 'Sciences'),
('Master Mathématiques', 'Formation avancée en mathématiques appliquées et recherche', 'Master', 'Mathématiques Appliquées');

-- Insérer des données dans la table annees_formation
INSERT INTO annees_formation (id_formation, niveau, nbr_max_etu) VALUES
(1, 'L1', 100),
(1, 'L2', 100),
(2, 'M1', 50);

-- Insérer des données dans la table semestres
INSERT INTO semestres (id_annee_formation, nom, date_debut, date_fin) VALUES
(1, 'Semestre 1', '2024-09-01', '2025-01-31'),
(1, 'Semestre 2', '2025-02-01', '2025-06-30'),
(3, 'Semestre 1', '2024-09-01', '2025-01-31');

-- Insérer des données dans la table unites_enseignement
INSERT INTO unites_enseignement (id_semestre, nom, coefficient) VALUES
(1, 'Programmation 1', 4.0),
(1, 'Algèbre Linéaire', 3.0),
(2, 'Bases de Données', 5.0),
(3, 'Analyse Avancée', 4.5);

-- Insérer des données dans la table elements_constitutif
-- Les enseignants doivent déjà être liés aux éléments constitutifs
INSERT INTO elements_constitutif (id_ue, numero_enseignant, nom, heures_cours, heures_td, heures_tp, modalites_evaluation) VALUES
(1, 1, 'Cours de Programmation', 30, 15, 10, 'Examen écrit et projet'),
(2, 2, 'Cours d''Algèbre', 25, 20, 5, 'Examen écrit'),
(3, 1, 'Bases de Données', 40, 10, 0, 'Examen écrit et projet'),
(4, 2, 'Analyse Mathématique', 35, 15, 5, 'Examen écrit et contrôle continu');

-- Insérer des données dans la table inscriptions
-- Les inscriptions doivent correspondre aux étudiants et aux années de formation existantes
INSERT INTO inscriptions (numero_etudiant, id_annee_formation, valide_le) VALUES
(1, 1, '2024-11-01 10:00:00'),
(2, 1, '2024-11-02 11:00:00'),
(3, 3, '2024-11-03 09:30:00');

-- Insérer des données dans la table notes_ec
-- Les notes doivent être attribuées aux inscriptions et aux éléments constitutifs existants
INSERT INTO notes_ec (id_inscription, id_ec, note) VALUES
(1, 1, 15.5),
(1, 2, 13.0),
(2, 3, 17.5),
(3, 4, 14.0);
