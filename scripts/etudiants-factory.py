from faker import Faker

# Initialize Faker for generating data
fake = Faker()


def generate_etudiants(personnes, num_etudiants=1000):
    """
    Generate student records based on personnes data.

    Args:
        personnes (list[dict]): List of personnes generated previously.
        num_etudiants (int): Number of students to generate.

    Returns:
        list[dict]: A list of dictionaries representing students.
        str: SQL INSERT script for the 'etudiants' table.
    """
    etudiants = []
    insert_statements = []

    # Select a subset of personnes to assign as students
    for i, personne in enumerate(personnes[:num_etudiants]):
        numero_etudiant = f"ETU{i + 1:05d}"
        etudiant = {
            "id_personne": personne["id_personne"],
            "numero_etudiant": numero_etudiant,
        }
        etudiants.append(etudiant)

        # Prepare SQL INSERT statement
        insert_statements.append(
            f"INSERT INTO etudiants (id_personne, numero_etudiant) "
            f"VALUES ({etudiant['id_personne']}, '{etudiant['numero_etudiant']}');"
        )

    # Combine all insert statements into one script
    sql_script = "\n".join(insert_statements)
    return etudiants, sql_script
