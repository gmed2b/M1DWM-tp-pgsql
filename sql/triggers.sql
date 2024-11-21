
-- Trigger pour vérifier le nombre maximum d'étudiants inscrits dans une formation
CREATE OR REPLACE FUNCTION verifier_inscription()
RETURNS TRIGGER AS $$
DECLARE
  _nbr_etudiant INT;
  _nbr_max_etu INT;
BEGIN
  -- Récupérer le nombre d'étudiants inscrits et le nombre maximum autorisé pour la formation
  SELECT nbr_inscrits, nbr_max_etu INTO _nbr_etudiant, _nbr_max_etu
  FROM vue_inscriptions_par_formation
  WHERE id_annee_formation = NEW.id_annee_formation;

  -- Vérification si le nombre d'étudiants dépasse le maximum autorisé
  IF _nbr_etudiant >= _nbr_max_etu THEN
    RAISE EXCEPTION 'Le nombre maximum d''étudiants pour cette formation est atteint';
  END IF;

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Application du trigger lors de l'insertion ou la mise à jour dans la table inscriptions
CREATE TRIGGER verification_inscription
BEFORE INSERT OR UPDATE ON inscriptions
FOR EACH ROW EXECUTE FUNCTION verifier_inscription();


-- Trigger pour vérifier l'ordre et la validation des inscriptions
CREATE OR REPLACE FUNCTION verifier_ordre_et_validation() 
RETURNS TRIGGER AS $$
DECLARE
  dernier_niveau VARCHAR(10);
  dernier_valide BOOLEAN;
BEGIN
  -- Récupérer le dernier niveau et la validation de l'année précédente
  SELECT niveau, est_valide
  INTO dernier_niveau, dernier_valide
  FROM vue_progression_etudiant
  WHERE numero_etudiant = NEW.numero_etudiant
    AND id_formation = (
      SELECT f.id_formation
      FROM annees_formation an
      JOIN formations f ON an.id_formation = f.id_formation
      WHERE an.id_annee_formation = NEW.id_annee_formation
    )
  ORDER BY derniere_date DESC
  LIMIT 1;

  -- Vérifier si l'année précédente est validée avant d'autoriser l'inscription
  IF dernier_niveau IS NOT NULL THEN
    IF NOT dernier_valide THEN
      RAISE EXCEPTION 'Inscription refusée : l''étudiant n''a pas validé l''année précédente';
    END IF;

    -- Vérification de la progression cohérente
    IF (
      (dernier_niveau = 'L1' AND NEW.niveau <> 'L2') OR
      (dernier_niveau = 'L2' AND NEW.niveau <> 'L3') OR
      (dernier_niveau = 'L3' AND NEW.niveau <> 'M1') OR
      (dernier_niveau = 'M1' AND NEW.niveau <> 'M2')
    ) THEN
      RAISE EXCEPTION 'Inscription non cohérente : l''étudiant ne peut pas s''inscrire à un niveau inférieur';
    END IF;
  END IF;

  RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Application du trigger lors de l'insertion dans la table inscriptions
CREATE TRIGGER verification_ordre_et_validation
BEFORE INSERT ON inscriptions
FOR EACH ROW
EXECUTE FUNCTION verifier_ordre_et_validation();
