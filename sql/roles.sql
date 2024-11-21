-- Créer au moins trois rôles distincts pour la base de données : étudiant,
-- enseignant et directeur des études. Seul le directeur des études pourra
-- modifier les formations. Les enseignants pourront mettre à jour les notes des
-- étudiants. Les étudiants ne pourront que faire des recherches sur les
-- formations et déposer des avis.

-- Création des roles
DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'etudiant') THEN

      RAISE NOTICE 'Role "etudiant" already exists. Skipping.';
   ELSE
      CREATE ROLE etudiant LOGIN PASSWORD 'mot_de_passe_etudiant';
   END IF;
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'enseignant') THEN

      RAISE NOTICE 'Role "enseignant" already exists. Skipping.';
   ELSE
      CREATE ROLE enseignant LOGIN PASSWORD 'mot_de_passe_enseignant';
   END IF;
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'directeur_des_etudes') THEN

      RAISE NOTICE 'Role "directeur_des_etudes" already exists. Skipping.';
   ELSE
      CREATE ROLE directeur_des_etudes LOGIN PASSWORD 'mot_de_passe_directeur_des_etudes';
   END IF;
END
$do$;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO directeur_des_etudes;
GRANT SELECT, INSERT, UPDATE ON TABLE
  formations, annees_formation,
  semestres, unites_enseignement,
  elements_constitutif, notes_ec,
  resultats
TO directeur_des_etudes;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO enseignant;
GRANT INSERT, UPDATE ON TABLE notes_ec TO enseignant;

GRANT INSERT, UPDATE ON TABLE avis_etudiant_formation TO etudiant;