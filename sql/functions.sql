CREATE OR REPLACE FUNCTION calcul_moyenne_etudiant(
    p_numero_etudiant INT,
    p_id_annee_formation INT,
    p_nom_semestre VARCHAR
) RETURNS NUMERIC(4, 2) AS $$
DECLARE
    moyenne_semestre NUMERIC(4, 2);
BEGIN
    -- Calcul de la moyenne du semestre pour un étudiant
    SELECT
        ROUND(SUM(ue.coefficient * subquery.moyenne_ec) / SUM(ue.coefficient), 2)
    INTO
        moyenne_semestre
    FROM
        unites_enseignement ue
    NATURAL JOIN semestres s
    NATURAL JOIN annees_formation af
    NATURAL JOIN formations f
    -- Sous-requête pour obtenir la moyenne des EC pour chaque UE de l'étudiant
    JOIN (
        SELECT
            ue.id_ue,
            AVG(ne.note) AS moyenne_ec
        FROM
            notes_ec ne
        NATURAL JOIN elements_constitutif ec
        NATURAL JOIN unites_enseignement ue
        NATURAL JOIN inscriptions ins
        WHERE
            ins.numero_etudiant = p_numero_etudiant
            AND ins.id_annee_formation = p_id_annee_formation
            AND s.nom = p_nom_semestre
        GROUP BY
            ue.id_ue
    ) AS subquery
    ON ue.id_ue = subquery.id_ue
    WHERE
        af.id_annee_formation = p_id_annee_formation
        AND s.nom = p_nom_semestre;

    -- Retourne la moyenne du semestre
    RETURN moyenne_semestre;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE preparation_deliberation(
    p_id_annee_formation INT
) AS $$
DECLARE
    rec RECORD;
    moyenne_s1 NUMERIC(4, 2);
    moyenne_s2 NUMERIC(4, 2);
    moyenne_finale NUMERIC(4, 2);
    resultat VARCHAR(10);
BEGIN
    -- Boucle sur chaque étudiant inscrit pour l'année de formation donnée
    FOR rec IN (
        SELECT numero_etudiant
        FROM inscriptions
        WHERE id_annee_formation = p_id_annee_formation
    ) LOOP
        -- Calcul de la moyenne du semestre 1
        SELECT calcul_moyenne_etudiant(rec.numero_etudiant, p_id_annee_formation, 'Semestre 1')
        INTO moyenne_s1;

        -- Calcul de la moyenne du semestre 2
        SELECT calcul_moyenne_etudiant(rec.numero_etudiant, p_id_annee_formation, 'Semestre 2')
        INTO moyenne_s2;

        -- Calcul de la moyenne finale (moyenne des deux semestres)
        moyenne_finale := ROUND((moyenne_s1 + moyenne_s2) / 2, 2);

        -- Définir le résultat en fonction de la moyenne finale
        IF moyenne_finale >= 10 THEN
            resultat := 'Validé';
        ELSE
            resultat := 'Ajourné';
        END IF;

        -- Mettre à jour l'inscription avec la validation et la mention
        UPDATE inscriptions
        SET valide_le = NOW(),
            mention = resultat
        WHERE numero_etudiant = rec.numero_etudiant
        AND id_annee_formation = p_id_annee_formation;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE fiche_de_notes(
    p_numero_etudiant INT,
    p_id_annee_formation INT,
    p_nom_semestre VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    -- Afficher les notes de l'étudiant pour chaque UE dans le semestre donné
    FOR rec IN (
        SELECT
            ue.nom AS ue_nom,
            ROUND(AVG(ne.note), 2) AS moyenne_ue
        FROM
            notes_ec ne
        NATURAL JOIN elements_constitutif ec
        NATURAL JOIN unites_enseignement ue
        NATURAL JOIN semestres s
        NATURAL JOIN annees_formation af
        NATURAL JOIN inscriptions ins
        WHERE
            ins.numero_etudiant = p_numero_etudiant
            AND ins.id_annee_formation = p_id_annee_formation
            AND s.nom = p_nom_semestre
        GROUP BY
            ue.nom
        ORDER BY
            ue.nom
    ) LOOP
        -- Affiche les résultats pour chaque UE
        RAISE NOTICE 'UE: %, Moyenne: %', rec.ue_nom, rec.moyenne_ue;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE archivage_resultats_anciens()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Créer la table d'archive si elle n'existe pas déjà
    CREATE TABLE IF NOT EXISTS resultats_archives (
        id_archive SERIAL PRIMARY KEY,
        id_inscription INT,
        numero_etudiant INT,
        id_annee_formation INT,
        valide_le TIMESTAMP,
        mention VARCHAR(255),
        archive_le TIMESTAMP DEFAULT NOW()
    );

    -- Déplacer les résultats de plus d'un an vers la table d'archive
    INSERT INTO resultats_archives (id_inscription, numero_etudiant, id_annee_formation, valide_le, mention)
    SELECT 
        id_inscription,
        numero_etudiant,
        id_annee_formation,
        valide_le,
        mention
    FROM 
        inscriptions
    WHERE 
        valide_le IS NOT NULL
        AND valide_le < NOW() - INTERVAL '1 year';

    -- Supprimer les résultats archivés de la table principale
    DELETE FROM inscriptions
    WHERE 
        valide_le IS NOT NULL
        AND valide_le < NOW() - INTERVAL '1 year';
END;
$$;
