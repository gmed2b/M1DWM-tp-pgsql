
------creation des vues
--accessible a tous
CREATE VIEW vue_formations AS
SELECT nom,description,niveau,departement
FROM formations;
GRANT SELECT ON vue_formations TO etudiant, enseignant, directeur_etudes;

---accessible aux enseignets et directeurs
CREATE VIEW vue_inscriptions_etudiants AS
SELECT i.id_inscription, e.numero_etudiant, p.nom, p.prenom, f.nom AS formation, a.niveau, i.valide_le
FROM inscriptions i
JOIN etudiants e ON i.numero_etudiant = e.numero_etudiant
JOIN personnes p ON e.id_personne = p.id_personne
JOIN annees_formation a ON i.id_annee_formation = a.id_annee_formation
JOIN formations f ON a.id_formation = f.id_formation;
GRANT SELECT ON vue_inscriptions_etudiants TO enseignant, directeur_etudes;

---aux enseignant
CREATE VIEW vue_notes_etudiants AS
SELECT i.numero_etudiant, p.nom AS etudiant_nom, e.id_ec, ec.nom AS element_constitutif, n.note
FROM notes_ec n
JOIN inscriptions i ON n.id_inscription = i.id_inscription
JOIN etudiants e ON i.numero_etudiant = e.numero_etudiant
JOIN personnes p ON e.id_personne = p.id_personne
JOIN elements_constitutif ec ON n.id_ec = ec.id_ec;
GRANT SELECT ON vue_notes_etudiants TO enseignant;

-----aux directeurs
CREATE VIEW vue_informations_enseignants AS
SELECT en.numero_enseignant, p.nom, p.prenom, en.specialite, en.departement
FROM enseignants en
JOIN personnes p ON en.id_personne = p.id_personne;
GRANT SELECT ON vue_informations_enseignants TO directeur_etudes;

-----accessibles uniquement aux directeurs et ensignients
CREATE VIEW vue_moyennes_etudiants AS
SELECT e.numero_etudiant, p.nom, p.prenom, AVG(n.note) AS moyenne_generale
FROM notes_ec n
JOIN inscriptions i ON n.id_inscription = i.id_inscription
JOIN etudiants e ON i.numero_etudiant = e.numero_etudiant
JOIN personnes p ON e.id_personne = p.id_personne
GROUP BY e.numero_etudiant, p.nom, p.prenom;
GRANT SELECT ON vue_moyennes_etudiants TO directeur_etudes;