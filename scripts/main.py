from faker import Faker
from Etudiant import Etudiant
from Enseignant import Enseignant
from Formation import Formation
from AnneeFormation import AnneeFormation
from Semestre import Semestre
from UniteEnseignement import UniteEnseignement
from ElementConstitutif import ElementConstitutif
from Inscription import Inscription
from NoteEc import NoteEc

fake = Faker()


def main():
    etudiants = Etudiant.generateMany(1000)
    enseignants = Enseignant.generateMany(200)
    formations = Formation.generateMany(15)
    annees_formations = []
    semestres = []
    ues = []
    ecs = []
    inscriptions = []
    notes = []

    for formation in formations:
        annees_formations.extend(AnneeFormation.generateMany(formation))
        for annee_formation in annees_formations:
            semestres.extend(Semestre.generateMany(annee_formation))
            for semestre in semestres:
                ues.extend(UniteEnseignement.generateMany(5, semestre))
                for ue in ues:
                    enseignant = fake.random_choices(enseignants, length=1)[0]
                    ecs.extend(ElementConstitutif.generateMany(10, ue, enseignant))

    # Inscriptions des etudiants a des formations
    for etudiant in etudiants:
        annee_formation = fake.random_choices(annees_formations, length=1)[0]
        inscription = Inscription.generate(etudiant, annee_formation)
        inscriptions.append(inscription)
        for ec in ecs:
            notes.append(NoteEc.generate(inscription, ec))

    insert_statements = []
    for etudiant in etudiants:
        insert_statements.append(
            f"INSERT INTO personnes VALUES ({etudiant['personne']['id_personne']}, '{etudiant['personne']['titre']}', '{etudiant['personne']['prenom']}',  '{etudiant['personne']['nom']}', '{etudiant['personne']['date_naissance']}', '{etudiant['personne']['email']}', '{etudiant['personne']['telephone']}', '{etudiant['personne']['adresse']}');"
        )
        insert_statements.append(
            f"INSERT INTO etudiants VALUES ({etudiant['numero_etudiant']}, {etudiant['id_personne']}, '{etudiant['email_etudiant']}');"
        )

    for enseignant in enseignants:
        insert_statements.append(
            f"INSERT INTO personnes VALUES ({enseignant['personne']['id_personne']}, '{enseignant['personne']['titre']}', '{enseignant['personne']['prenom']}',  '{enseignant['personne']['nom']}', '{enseignant['personne']['date_naissance']}', '{enseignant['personne']['email']}', '{enseignant['personne']['telephone']}', '{enseignant['personne']['adresse']}');"
        )
        insert_statements.append(
            f"INSERT INTO enseignants VALUES ({enseignant['numero_enseignant']}, {enseignant['id_personne']}, '{enseignant['specialite']}', '{enseignant['departement']}');"
        )

    for formation in formations:
        insert_statements.append(
            f"INSERT INTO formations VALUES ({formation['id_formation']}, '{formation['nom']}', '{formation['description']}', '{formation['niveau']}', '{formation['departement']}');"
        )

    for annee_formation in annees_formations:
        insert_statements.append(
            f"INSERT INTO annees_formation VALUES ({annee_formation['id_annee_formation']}, {annee_formation['id_formation']}, '{annee_formation['date_formation'].strftime("%Y-%m-%d")}', '{annee_formation['niveau']}', {annee_formation['nbr_max_etu']});"
        )

    for semestre in semestres:
        insert_statements.append(
            f"INSERT INTO semestres VALUES ({semestre['id_semestre']}, {semestre['id_annee_formation']}, '{semestre['semestre']}', '{semestre['date_debut']}', '{semestre['date_fin']}');"
        )

    for ue in ues:
        insert_statements.append(
            f"INSERT INTO unites_enseignement VALUES ({ue['id_ue']}, {ue['id_semestre']}, '{ue['nom']}', '{ue['description']}', {ue['coefficient']}, {ue['obligatoire']});"
        )

    for ec in ecs:
        insert_statements.append(
            f"INSERT INTO elements_constitutif VALUES ({ec['id_ec']}, {ec['id_ue']}, {ec['numero_enseignant']}, '{ec['nom']}', {ec['heures_cours']}, {ec['heures_td']}, {ec['heures_tp']}, '{ec['modalites_evaluation']}');"
        )

    for inscription in inscriptions:
        insert_statements.append(
            f"INSERT INTO inscriptions VALUES ({inscription['id_inscription']}, {inscription['numero_etudiant']}, {inscription['id_annee_formation']}, '{inscription['date_inscription']}', '{inscription['valide_le']}', '{inscription['mention']}');"
        )

    for note in notes:
        insert_statements.append(
            f"INSERT INTO notes_ec VALUES ({note['id_inscription']}, {note['id_ec']}, {note['note']});"
        )

    sql_script = "\n".join(insert_statements)

    with open("data.sql", "w") as f:
        f.write(sql_script)

    print("Data generated successfully!")


if __name__ == "__main__":
    main()
