
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
    s.nom AS semestre_nom,
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
ORDER BY f.nom, af.niveau, s.nom, ue.nom, ec.nom;


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
