-- R1

WITH formations_frequentees AS (
  SELECT 
      f.id_formation, 
      COUNT(e.numero_etudiant) AS total_etudiants
  FROM formations f
  NATURAL JOIN annees_formation af
  NATURAL JOIN inscriptions i
  NATURAL JOIN etudiants e
  WHERE af.date_formation >= 2010
  GROUP BY f.id_formation
  HAVING COUNT(e.numero_etudiant) > 5
)
SELECT 
    af.annee AS annee_academique, 
    af.id_annee_formation, 
    COUNT(i.id_etudiant) AS nombre_etudiants, 
    AVG(n.note_finale) AS moyenne_notes
FROM formations_frequentees ff
JOIN annees_formation af ON ff.id_formation = af.id_formation
JOIN inscriptions i ON af.id_annee_formation = i.id_annee_formation
JOIN notes n ON i.id_inscription = n.id_inscription
GROUP BY af.annee, af.id_annee_formation
ORDER BY annee_academique;


SELECT 
    af.annee AS annee_academique, 
    af.id_annee_formation, 
    COUNT(i.id_etudiant) AS nombre_etudiants, 
    AVG(n.note_finale) AS moyenne_notes
FROM annees_formation af
JOIN formations f ON af.id_formation = f.id_formation
JOIN inscriptions i ON af.id_annee_formation = i.id_annee_formation
JOIN notes n ON i.id_inscription = n.id_inscription
WHERE af.annee >= 2010
GROUP BY af.annee, af.id_annee_formation
HAVING COUNT(i.id_etudiant) > 5
ORDER BY annee_academique;



-- R2

WITH moyenne_generale AS (
    SELECT AVG(n.note_finale) AS moyenne_notes
    FROM annees_formation af
    JOIN inscriptions i ON af.id_annee_formation = i.id_annee_formation
    JOIN notes n ON i.id_inscription = n.id_inscription
    WHERE af.id_annee_formation = 1 AND af.annee = '2023-2024'
)
SELECT 
    mat.intitule_matiere,
    CONCAT(p.nom, ' ', p.prenom) AS enseignant_responsable
FROM matieres mat
JOIN enseignants e ON mat.id_enseignant = e.id_personne
JOIN personnes p ON e.id_personne = p.id_personne
WHERE mat.id_matiere NOT IN (
    SELECT DISTINCT n.id_matiere
    FROM annees_formation af
    JOIN inscriptions i ON af.id_annee_formation = i.id_annee_formation
    JOIN notes n ON i.id_inscription = n.id_inscription
    WHERE af.id_annee_formation = 1 
    AND af.annee = '2023-2024' 
    AND n.note_finale < (SELECT moyenne_notes FROM moyenne_generale)
);


SELECT 
    mat.intitule_matiere,
    CONCAT(p.nom, ' ', p.prenom) AS enseignant_responsable
FROM annees_formation af
JOIN inscriptions i ON af.id_annee_formation = i.id_annee_formation
JOIN notes n ON i.id_inscription = n.id_inscription
JOIN matieres mat ON n.id_matiere = mat.id_matiere
JOIN enseignants e ON mat.id_enseignant = e.id_personne
JOIN personnes p ON e.id_personne = p.id_personne
WHERE af.id_annee_formation = 1 
  AND af.annee = '2023-2024'
GROUP BY mat.intitule_matiere, e.id_personne, p.nom, p.prenom
HAVING MIN(n.note_finale) >= AVG(n.note_finale);



-- R3

WITH etudiants_moyenne_inferieure AS (
    SELECT 
        i.id_etudiant,
        af.id_formation
    FROM annees_formation af
    JOIN inscriptions i ON af.id_annee_formation = i.id_annee_formation
    JOIN notes n ON i.id_inscription = n.id_inscription
    WHERE af.annee = '2023-2024'
    GROUP BY i.id_etudiant, af.id_formation
    HAVING AVG(n.note_finale) < 4
)
SELECT DISTINCT f.nom_filiere
FROM formations f
WHERE f.id_formation NOT IN (
    SELECT DISTINCT em.id_formation
    FROM etudiants_moyenne_inferieure em
);


SELECT 
    f.nom_filiere
FROM formations f
JOIN annees_formation af ON f.id_formation = af.id_formation
JOIN inscriptions i ON af.id_annee_formation = i.id_annee_formation
JOIN notes n ON i.id_inscription = n.id_inscription
WHERE af.annee = '2023-2024'
GROUP BY f.id_formation, f.nom_filiere
HAVING MIN(
    AVG(n.note_finale) OVER (PARTITION BY i.id_etudiant)
) >= 4;
