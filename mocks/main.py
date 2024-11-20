import random
from faker import Faker
import datetime

# Initialisation de Faker
fake = Faker()

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
        start_date, end_date = generate_dates_for_year(2023)  # Exemple pour l'année 2023
        validation_state = random.choice(["En attente", "Validée", "Rejetée"])  # État d'inscription
        inscriptions.append((etudiant_id, annee_formation_id, start_date, validation_state))
    return inscriptions

# Fonction pour générer des étudiants fictifs
def generate_students(num_students):
    students = []
    for _ in range(num_students):
        first_name = fake.first_name()
        last_name = fake.last_name()
        birth_date = fake.date_of_birth(minimum_age=18, maximum_age=30)
        email = fake.email()
        phone = fake.phone_number()
        address = fake.address()
        titre = random.choice(["M.", "Mme", "Dr.", "Pr."])
        students.append((titre, first_name, last_name, birth_date, email, phone, address))
    return students

# Fonction pour générer des formations fictives
def generate_formations():
    formations = []
    for year in range(2005, 2025):  # De 2005 à 2024
        formations.append(('Licence Informatique', 'Formation en informatique', 'Licence', 'Informatique', 'Aucun prérequis'))
        formations.append(('Master Informatique', 'Formation en informatique avancée', 'Master', 'Informatique', 'Licence en Informatique'))
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
            date_fin = datetime.date(annee[0], 12, 20)  # Semestre se termine en décembre
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
            unites.append((semestre[0], f"UE{i} - {semestre[1]}", random.uniform(1.0, 3.0), description, obligatoire))
    return unites

# Fonction pour générer des éléments constitutifs
def generate_elements_constitutifs(unites, enseignants):
    elements = []
    for unite in unites:
        enseignant_id = random.choice(enseignants)[0]
        evaluation_type = random.choice(["Examen", "Projet", "Présentation"])
        elements.append((unite[0], enseignant_id, unite[1], random.randint(10, 30), random.randint(5, 10), random.randint(2, 5), evaluation_type))
    return elements

# Fonction pour générer des inscriptions d'étudiants pour chaque année de formation
def generate_inscriptions_for_years(annees, students):
    inscriptions = []
    for annee in annees:
        annee_formation_id = annee[0]
        num_students = random.randint(2, annee[2])  # Nombre d'étudiants par année
        inscriptions.extend(generate_inscriptions(annee_formation_id, num_students, annee[2]))
    return inscriptions

# Fonction pour générer les notes
def generate_notes(elements, inscriptions):
    notes = []
    for inscription in inscriptions:
        for element in elements:
            note = round(random.uniform(10.0, 20.0), 1)  # Note entre 10 et 20
            evaluation_date = fake.date_this_year()
            notes.append((inscription[0], element[0], note, evaluation_date))
    return notes

# Génération des données fictives
students = generate_students(1000)  # Générer 1000 étudiants
formations = generate_formations()  # Générer les formations
annees = generate_annees_formation(formations)  # Générer les années de formation
semestres = generate_semestres(annees)  # Générer les semestres
unites = generate_unites_enseignement(semestres)  # Générer les unités d'enseignement
enseignants = [(i, fake.name(), random.choice(["Algorithmique", "Réseaux", "Bases de données", "Systèmes embarqués", "IA"])) for i in range(1, 51)]  # Générer des enseignants fictifs avec spécialités
elements = generate_elements_constitutifs(unites, enseignants)  # Générer les éléments constitutifs
inscriptions = generate_inscriptions_for_years(annees, students)  # Générer les inscriptions des étudiants
notes = generate_notes(elements, inscriptions)  # Générer les notes

# Fonction pour générer des scripts SQL d'insertion
def generate_sql_insert(table_name, data):
    sql = f"INSERT INTO {table_name} VALUES\n"
    sql += ",\n".join([f"({', '.join(map(str, row))})" for row in data])
    sql += ";"
    return sql

# Sauvegarde des données dans des fichiers SQL
with open('insert_personnes.sql', 'w') as file:
    file.write(generate_sql_insert('personnes', students))

with open('insert_formations.sql', 'w') as file:
    file.write(generate_sql_insert('formations', formations))

with open('insert_annees_formation.sql', 'w') as file:
    file.write(generate_sql_insert('annees_formation', annees))

with open('insert_semestres.sql', 'w') as file:
    file.write(generate_sql_insert('semestres', semestres))

with open('insert_unites_enseignement.sql', 'w') as file:
    file.write(generate_sql_insert('unites_enseignement', unites))

with open('insert_elements_constitutif.sql', 'w') as file:
    file.write(generate_sql_insert('elements_constitutif', elements))

with open('insert_inscriptions.sql', 'w') as file:
    file.write(generate_sql_insert('inscriptions', inscriptions))

with open('insert_notes_ec.sql', 'w') as file:
    file.write(generate_sql_insert('notes_ec', notes))
