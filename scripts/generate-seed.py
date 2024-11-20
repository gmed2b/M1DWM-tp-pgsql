import random
from faker import Faker
import datetime
import os

# Initialisation de Faker
fake = Faker()

# Mise à jour du script pour générer un fichier global et des fichiers séparés pour chaque table.


def main_optimized():
    print("Génération des données fictives pour la base de données...")

    # Supprime les fichiers existants
    for file in os.listdir("scripts/sql-out"):
        os.remove(f"scripts/sql-out/{file}")

    # Génération des données
    personnes = generate_personnes(5000)  # 5000 personnes
    students = generate_etudiants(personnes[:4000])  # 3000 étudiants
    enseignants = generate_enseignants(
        personnes[4000:]
    )  # Le reste sont des enseignants
    formations = generate_formations()
    annees = generate_annees_formation(formations)
    semestres = generate_semestres(annees)
    unites = generate_unites_enseignement(semestres)
    elements = generate_elements_constitutifs(unites, enseignants)
    inscriptions = generate_inscriptions_for_years(annees, students)
    notes = generate_notes(elements, inscriptions)

    # Fonction pour générer des scripts SQL d'insertion
    def generate_sql_insert(table_name, data):
        sql = f"INSERT INTO {table_name} VALUES\n"
        sql += ",\n".join([f"({', '.join(map(repr, row))})" for row in data])
        sql += ";\n"
        return sql

    DEST_FOLDER = "scripts/sql-out"
    if not os.path.exists(DEST_FOLDER):
        os.makedirs(DEST_FOLDER)

    all_sql_content = ""

    # Sauvegarde des données dans des fichiers SQL et construction du fichier global
    for table_name, data in [
        ("personnes", personnes),
        ("etudiants", students),
        ("enseignants", enseignants),
        ("formations", formations),
        ("annees_formation", annees),
        ("semestres", semestres),
        ("unites_enseignement", unites),
        ("elements_constitutif", elements),
        ("inscriptions", inscriptions),
        ("notes_ec", notes),
    ]:
        file_path = f"{DEST_FOLDER}/insert_{table_name}.sql"
        sql_content = generate_sql_insert(table_name, data)
        all_sql_content += sql_content + "\n"

        with open(file_path, "w") as file:
            print(f"Génération des données pour la table {table_name}...")
            file.write(sql_content)

    # Sauvegarde du fichier global
    with open(f"{DEST_FOLDER}/insert_all.sql", "w") as global_file:
        print("Génération du fichier global contenant toutes les insertions...")
        global_file.write(all_sql_content)

    print("Génération des fichiers terminée.")

    # Fonction pour générer des personnes fictives


def generate_personnes(num_personnes):
    personnes = []
    for i in range(1, num_personnes + 1):
        titre = random.choice(["M.", "Mme", "Dr.", "Pr."])
        nom = fake.last_name()
        prenom = fake.first_name()
        date_naissance = fake.date_of_birth(minimum_age=18, maximum_age=80)
        email = fake.email()
        telephone = fake.phone_number()
        adresse = fake.address()
        personnes.append(
            (i, titre, nom, prenom, date_naissance, email, telephone, adresse)
        )
    return personnes


# Fonction pour générer des étudiants à partir de personnes
def generate_etudiants(personnes):
    etudiants = []
    for personne in personnes:
        etudiants.append((personne[0], random.choice(["Licence", "Master"])))
    return etudiants


# Fonction pour générer des enseignants à partir de personnes
def generate_enseignants(personnes):
    enseignants = []
    for personne in personnes:
        specialite = random.choice(
            ["Algorithmique", "Réseaux", "Bases de données", "Systèmes embarqués", "IA"]
        )
        enseignants.append((personne[0], specialite))
    return enseignants


# Fonction pour générer des dates d'inscriptions cohérentes
def generate_dates_for_year(year):
    start_date = datetime.date(year, 9, 1)  # Début d'année académique
    end_date = datetime.date(year + 1, 6, 30)  # Fin d'année académique
    return start_date, end_date


# Fonction pour générer des inscriptions
def generate_inscriptions(annee_formation_id, num_etudiants, max_inscription):
    inscriptions = []
    for _ in range(num_etudiants):
        etudiant_id = random.randint(1, 1000)  # Identifier des étudiants fictifs
        start_date, end_date = generate_dates_for_year(
            2023
        )  # Exemple pour l'année 2023
        validation_state = random.choice(
            ["En attente", "Validée", "Rejetée"]
        )  # État d'inscription
        inscriptions.append(
            (etudiant_id, annee_formation_id, start_date, validation_state)
        )
    return inscriptions


# Fonction pour générer des formations fictives
def generate_formations():
    formations = []
    for year in range(2005, 2025):  # De 2005 à 2024
        formations.append(
            (
                "Licence Informatique",
                "Formation en informatique",
                "Licence",
                "Informatique",
                "Aucun prérequis",
            )
        )
        formations.append(
            (
                "Master Informatique",
                "Formation en informatique avancée",
                "Master",
                "Informatique",
                "Licence en Informatique",
            )
        )
    return formations


# Fonction pour générer des années de formation
def generate_annees_formation(formations):
    annees = []
    for formation in formations:
        formation_id = random.randint(1, 10)
        niveau = formation[2]  # Licence ou Master
        max_etu = random.randint(10, 100)  # Nombre max d'étudiants par année
        annees.append((formation_id, niveau, max_etu))
    return annees


# Fonction pour générer des semestres
def generate_semestres(annees):
    semestres = []
    for annee in annees:
        for niveau in ["S1", "S2"]:
            date_debut = datetime.date(annee[0], 9, 1)  # Semestre commence en septembre
            date_fin = datetime.date(
                annee[0], 12, 20
            )  # Semestre se termine en décembre
            duree = (date_fin - date_debut).days  # Calcul de la durée en jours
            semestres.append((annee[0], niveau, date_debut, date_fin, duree))
    return semestres


# Fonction pour générer des unités d'enseignement
def generate_unites_enseignement(semestres):
    unites = []
    for semestre in semestres:
        for i in range(1, 4):  # 3 unités d'enseignement par semestre
            description = f"Description de l'UE{i} pour le semestre {semestre[1]}"
            obligatoire = random.choice([True, False])
            unites.append(
                (
                    semestre[0],
                    f"UE{i} - {semestre[1]}",
                    random.uniform(1.0, 3.0),
                    description,
                    obligatoire,
                )
            )
    return unites


# Fonction pour générer des éléments constitutifs
def generate_elements_constitutifs(unites, enseignants):
    elements = []
    for unite in unites:
        enseignant_id = random.choice(enseignants)[0]
        evaluation_type = random.choice(["Examen", "Projet", "Présentation"])
        elements.append(
            (
                unite[0],
                enseignant_id,
                unite[1],
                random.randint(10, 30),
                random.randint(5, 10),
                random.randint(2, 5),
                evaluation_type,
            )
        )
    return elements


# Fonction pour générer des inscriptions d'étudiants pour chaque année de formation
def generate_inscriptions_for_years(annees, students):
    inscriptions = []
    for annee in annees:
        annee_formation_id = annee[0]
        num_students = random.randint(2, annee[2])  # Nombre d'étudiants par année
        inscriptions.extend(
            generate_inscriptions(annee_formation_id, num_students, annee[2])
        )
    return inscriptions


# Fonction pour générer les notes
def generate_notes(elements, inscriptions):
    notes = []
    for inscription in inscriptions:
        for element in elements:
            note = round(random.uniform(0, 20.0), 1)  # Note entre 10 et 20
            evaluation_date = fake.date_this_year()
            notes.append((inscription[0], element[0], note, evaluation_date))
    return notes


if __name__ == "__main__":
    main_optimized()
