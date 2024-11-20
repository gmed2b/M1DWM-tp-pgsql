import random
from faker import Faker
import psycopg2
from datetime import datetime, timedelta

# Initialisation de Faker
fake = Faker()

# Connexion à la base de données PostgreSQL
conn = psycopg2.connect(
    dbname="tpbd",
    user="postgres",
    password="postgres",
    host="localhost",
    port="5445"
)
cursor = conn.cursor()

# Fonction pour générer des personnes (étudiants et enseignants)
def generate_persons(num_persons):
    persons = []
    for _ in range(num_persons):
        prenom = fake.first_name()
        nom = fake.last_name()
        date_naissance = fake.date_of_birth(minimum_age=18, maximum_age=30)  
        email = fake.email()
        telephone = fake.phone_number()
        adresse = fake.address()
        
        persons.append((prenom, nom, date_naissance, email, telephone, adresse))
    
    return persons

# Fonction pour insérer des personnes dans la base
def insert_persons(persons):
    for person in persons:
        cursor.execute("""
            INSERT INTO personnes (prenom, nom, date_naissance, email, telephone, adresse) 
            VALUES (%s, %s, %s, %s, %s, %s) RETURNING id_personne;
        """, person)
        person_id = cursor.fetchone()[0]
        cursor.execute("INSERT INTO etudiants (id_personne, email_etudiant) VALUES (%s, %s)", (person_id, person[3]))
        
# Générer et insérer 1000 personnes
persons = generate_persons(1000)
insert_persons(persons)

# Fonction pour générer des formations
def generate_formations():
    formations = [
        ('Licence Informatique', 'Formation en informatique couvrant programmation, bases de données, réseaux, etc.', 'Licence', 'Sciences'),
        ('Master Mathématiques', 'Formation avancée en mathématiques appliquées et recherche', 'Master', 'Mathématiques Appliquées')
    ]
    return formations

# Insérer les formations
formations = generate_formations()
for formation in formations:
    cursor.execute("""
        INSERT INTO formations (nom, description, niveau, departement) 
        VALUES (%s, %s, %s, %s) RETURNING id_formation;
    """, formation)
    formation_id = cursor.fetchone()[0]
    
    # Ajouter les années de formation (L1, L2, L3 pour Licence, M1, M2 pour Master)
    if formation[2] == 'Licence':
        for niveau in ['L1', 'L2', 'L3']:
            cursor.execute("""
                INSERT INTO annees_formation (id_formation, niveau, nbr_max_etu) 
                VALUES (%s, %s, %s);
            """, (formation_id, niveau, random.randint(50, 150)))  # Nombre d'étudiants variable
    else:
        for niveau in ['M1', 'M2']:
            cursor.execute("""
                INSERT INTO annees_formation (id_formation, niveau, nbr_max_etu) 
                VALUES (%s, %s, %s);
            """, (formation_id, niveau, random.randint(20, 100)))

# Générer des inscriptions pour chaque année de formation
def generate_inscriptions():
    cursor.execute("SELECT id_formation, id_annee_formation FROM annees_formation")
    formations_annees = cursor.fetchall()
    
    for id_formation, id_annee_formation in formations_annees:
        cursor.execute("SELECT id_personne FROM personnes")
        students = cursor.fetchall()
        
        for student_id in students:
            student_id = student_id[0]
            
            # Assurer que l'étudiant n'a pas plus de 2 inscriptions pour la même année
            cursor.execute("""
                SELECT COUNT(*) FROM inscriptions WHERE numero_etudiant = %s AND id_annee_formation = %s;
            """, (student_id, id_annee_formation))
            count = cursor.fetchone()[0]
            if count < 2:
                # Inscription
                date_inscription = fake.date_this_decade()
                cursor.execute("""
                    INSERT INTO inscriptions (numero_etudiant, id_annee_formation, valide_le) 
                    VALUES (%s, %s, %s);
                """, (student_id, id_annee_formation, date_inscription))

# Générer les inscriptions
generate_inscriptions()

# Commit des changements
conn.commit()

# Fermeture de la connexion
cursor.close()
conn.close()
