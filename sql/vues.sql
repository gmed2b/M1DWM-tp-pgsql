
-- Affiche une liste détaillée regroupant toutes les informations nécessaires
-- sur les formations, triées par formation, année, semestre, UE et EC.
CREATE OR REPLACE VIEW vue_maquettes_formations AS
SELECT
    f.nom AS formation_nom,
    f.description AS formation_description,
    f.niveau AS formation_niveau,
    f.departement AS formation_departement,
    af.niveau AS annee_niveau,
    af.nbr_max_etu AS annee_nombre_max_etudiants,
    s.semestre AS semestre_nom,
    s.date_debut AS semestre_date_debut,
    s.date_fin AS semestre_date_fin,
    ue.nom AS ue_nom,
    ue.coefficient AS ue_coefficient,
    ec.nom AS ec_nom,
    ec.heures_cours AS ec_heures_cours,
    ec.heures_td AS ec_heures_td,
    ec.heures_tp AS ec_heures_tp,
    ec.modalites_evaluation AS ec_modalites_evaluation,
    CONCAT(p.prenom, ' ', p.nom) AS enseignant_responsable
FROM formations f
NATURAL JOIN annees_formation af
NATURAL JOIN semestres s
NATURAL JOIN unites_enseignement ue
NATURAL JOIN elements_constitutif ec
NATURAL JOIN enseignants ens
NATURAL JOIN personnes p
ORDER BY f.nom, af.niveau, s.semestre, ue.nom, ec.nom;


-- Affiche la liste des étudiants inscrits par année de formation,
-- avec leurs informations personnelles.
CREATE OR REPLACE VIEW vue_liste_etudiants_inscrits AS
SELECT
    i.id_inscription,
    etu.numero_etudiant,
    p.prenom,
    p.nom,
    p.email,
    p.telephone,
    af.niveau AS annee_niveau,
    f.nom AS formation_nom,
    i.valide_le,
    i.mention
FROM inscriptions i
NATURAL JOIN etudiants etu
NATURAL JOIN personnes p
NATURAL JOIN annees_formation af
NATURAL JOIN formations f
ORDER BY f.nom, af.niveau, p.nom, p.prenom;


-- Affiche le nombre d'étudiants inscrits par formation, avec le nombre maximum autorisé.
CREATE OR REPLACE VIEW vue_inscriptions_par_formation AS
SELECT
    an.id_annee_formation,
    f.nom AS formation_nom,
    COUNT(ins.numero_etudiant) AS nbr_inscrits,
    an.nbr_max_etu
FROM annees_formation an
LEFT JOIN inscriptions ins USING an.id_annee_formation
NATURAL JOIN formations f
GROUP BY an.id_annee_formation, an.nbr_max_etu;


-- Affiche la progression des étudiants par formation, avec indication de la validation.
CREATE OR REPLACE VIEW vue_progression_etudiant AS
SELECT
    ins.numero_etudiant,
    an.id_formation,
    an.niveau,
    MAX(an.date_formation) AS derniere_date,
    CASE 
        WHEN MAX(ins.valide_le) IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS est_valide
FROM inscriptions ins
NATURAL JOIN annees_formation an
GROUP BY ins.numero_etudiant, an.id_formation, an.niveau;


-- Affiche les notes obtenues par les étudiants par semestre, UE et EC.
CREATE OR REPLACE VIEW vue_notes_etudiant_par_semestre AS
SELECT
    s.semestre AS semestre_nom,
    f.nom AS formation_nom,
    af.niveau AS annee_niveau,
    ue.nom AS ue_nom,
    ue.coefficient AS ue_coefficient,
    ec.nom AS ec_nom,
    etu.numero_etudiant,
    p.prenom AS etudiant_prenom,
    p.nom AS etudiant_nom,
    ne.note AS note_obtenue
FROM
    notes_ec ne
NATURAL JOIN inscriptions ins
NATURAL JOIN etudiants etu
NATURAL JOIN personnes p
NATURAL JOIN annees_formation af
NATURAL JOIN formations f
NATURAL JOIN semestres s
NATURAL JOIN unites_enseignement ue
NATURAL JOIN elements_constitutif ec
ORDER BY s.semestre, f.nom, af.niveau, etu.numero_etudiant, ue.nom, ec.nom;


-- Affiche un planning detaille des semestres, UE et EC par formation.
CREATE OR REPLACE VIEW vue_planning_semestres AS
SELECT
    f.nom AS formation_nom,
    f.niveau AS formation_niveau,
    af.niveau AS annee_niveau,
    s.semestre AS semestre_nom,
    s.date_debut AS semestre_date_debut,
    s.date_fin AS semestre_date_fin,
    ec.nom AS ec_nom,
    CONCAT(p.prenom, ' ', p.nom) AS enseignant_responsable
FROM
    formations f
NATURAL JOIN annees_formation af
NATURAL JOIN semestres s
NATURAL JOIN unites_enseignement ue
NATURAL JOIN elements_constitutif ec
NATURAL JOIN enseignants ens
NATURAL JOIN personnes p
ORDER BY f.nom, af.niveau, s.semestre, ec.nom;
