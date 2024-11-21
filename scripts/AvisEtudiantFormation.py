from faker import Faker
from Formation import Formation
from Etudiant import Etudiant

# Initialize Faker for generating data
fake = Faker()


class AvisEtudiantFormation:

    @staticmethod
    def generate(formation: Formation, etudiant: Etudiant):
        formation = formation if formation else Formation.generate()
        etudiant = etudiant if etudiant else Etudiant.generate()

        return {
            "id_formation": formation["id_formation"],
            "numero_etudiant": etudiant["numero_etudiant"],
            "avis": fake.text(),
        }
