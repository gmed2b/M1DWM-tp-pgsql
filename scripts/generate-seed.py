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
    etudiants = generate_etudiants(personnes[:4000])  # 3000 étudiants
    enseignants = generate_enseignants(
        personnes[4000:]
    )  # Le reste sont des enseignants
    formations = generate_formations()
    annees = generate_annees_formation(formations)
    semestres = generate_semestres(annees)
    unites = generate_unites_enseignement(semestres)
    elements = generate_elements_constitutifs(unites, random.choice(enseignants)[0])
    inscriptions = generate_inscriptions(annees, etudiants)
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
        ("etudiants", etudiants),
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
            (
                i,
                titre,
                nom,
                prenom,
                date_naissance.strftime("%Y-%m-%d"),
                email,
                telephone,
                adresse,
            )
        )
    return personnes


# Fonction pour générer des étudiants à partir de personnes
def generate_etudiants(personnes):
    etudiants = []
    for personne in personnes:
        numero_etudiant = personne[0]
        email_etudiant = str(numero_etudiant) + "@etu.com"
        etudiants.append((numero_etudiant, email_etudiant))
    return etudiants


# Fonction pour générer des enseignants à partir de personnes
def generate_enseignants(personnes):
    enseignants = []
    for personne in personnes:
        numero_enseignant = personne[0]
        specialite = random.choice(
            ["Algorithmique", "Réseaux", "Bases de données", "Systèmes embarqués", "IA"]
        )
        departement = random.choice(["Science", "Lettres", "Economie"])
        enseignants.append((personne[0], specialite, departement))
    return enseignants


# Fonction pour générer des formations fictives
def generate_formations():
    formations = []
    for _ in range(1, random.randint(10, 20)):
        nom = random.choice(
            [
                "Informatique",
                "Mathématiques",
                "Droit",
                "Physique",
                "Economie",
                "Chimie",
                "Biologie",
                "Géologie",
                "Gestion",
            ]
        )
        description = fake.text()
        niveau = random.choice(["Licence", "Master"])
        departement = random.choice(["Science", "Lettres", "Economie"])
        formations.append((nom, description, niveau, departement))
    return formations


# Fonction pour générer des années de formation
def generate_annees_formation(formations):
    annees = []
    current_year = datetime.datetime.now().year
    for formation in formations:
        for year in range(2005, current_year + 1):
            niveau_license = ["L1", "L2", "L3"]
            niveau_master = ["M1", "M2"]
            niveau = (
                random.choice(niveau_license)
                if formation[2] == "Licence"
                else random.choice(niveau_master)
            )
            date_formation = datetime.date(year, 9, 1)  # Début de l'année de formation
            nbr_max_etu = random.randint(50, 300)  # Nombre maximum d'étudiants
            annees.append(
                (formation[0], date_formation.strftime("%Y-%m-%d"), niveau, nbr_max_etu)
            )
    return annees


# Fonction pour générer des semestres
def generate_semestres(annees):
    semestres = []
    for annee in annees:
        annee_semestre_1 = datetime.datetime.strptime(annee[1][0:4], "%Y").year
        semestres.append(
            (
                annee[0],
                "Semestre 1",
                datetime.date(annee_semestre_1, 9, 1).strftime("%Y-%m-%d"),
                datetime.date(annee_semestre_1, 12, 31).strftime("%Y-%m-%d"),
            )
        )
        annee_semestre_2 = datetime.datetime.strptime(annee[1][0:4], "%Y").year + 1
        semestres.append(
            (
                annee[0],
                "Semestre 2",
                datetime.date(annee_semestre_2, 1, 1).strftime("%Y-%m-%d"),
                datetime.date(annee_semestre_2, 6, 30).strftime("%Y-%m-%d"),
            )
        )
    return semestres


# Fonction pour générer des unités d'enseignement
def generate_unites_enseignement(semestres):
    unites = []
    for semestre in semestres:
        for i in range(1, 4):  # 3 unités d'enseignement par semestre
            nom = f"UE{i} - {fake.word()}"
            description = fake.text()
            coefficient = round(random.uniform(1.0, 10.0), 2)
            obligatoire = random.choice([True, False])
            unites.append(
                (
                    semestre[0],
                    nom,
                    description,
                    coefficient,
                    obligatoire,
                )
            )
    return unites


# Fonction pour générer des éléments constitutifs
def generate_elements_constitutifs(unites, numero_enseignant):
    elements = []
    for unite in unites:
        nom = f"EC - {fake.word()}"
        heures_cours = random.randint(10, 30)
        heures_td = random.randint(5, 10)
        heures_tp = random.randint(2, 5)
        modalites_evaluation = random.choice(["Examen", "Projet", "Présentation"])
        elements.append(
            (
                unite[0],
                numero_enseignant,
                nom,
                heures_cours,
                heures_td,
                heures_tp,
                modalites_evaluation,
            )
        )
    return elements


# Fonction pour générer des inscriptions
def generate_inscriptions(annees, etudiants):
    inscriptions = []
    for annee in annees:
        nbr_etudiants_choisie = random.randint(2, annee[3])
        for _ in range(nbr_etudiants_choisie):
            etudiant = random.choice(etudiants)

            # si l'inscription de l'etudiant est pour l'année en cours
            # alors on ne lui valide pas encore l'annee
            if annee[1][0:4] == datetime.datetime.now().strftime("%Y"):
                inscriptions.append((etudiant[0], annee[0], None))
            else:
                mention = random.choice(["Passable", "Assez Bien", "Bien", "Très Bien"])
                inscriptions.append((etudiant[0], annee[0], annee[1], mention))

    return inscriptions


# Fonction pour générer les notes
def generate_notes(elements, inscriptions):
    notes = []
    for inscription in inscriptions:
        if inscription[2] is None:
            continue

        for element in elements:
            note = round(random.uniform(0, 20.0))
            notes.append((inscription[0], element[0], note))
    return notes


if __name__ == "__main__":
    main_optimized()
