from faker import Faker
import random
from Etudiant import Etudiant
from AnneeFormation import AnneeFormation
from Semestre import Semestre

# Initialize Faker for generating data
fake = Faker()


class Resultat:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate(
        etudiant: Etudiant, annee_formation: AnneeFormation, semestre: Semestre
    ):
        Resultat._id += 1

        etudiant = etudiant if etudiant else Etudiant.generate()
        annee_formation = (
            annee_formation if annee_formation else AnneeFormation.generate()
        )
        semestre = semestre if semestre else Semestre.generateSemestre()

        return {
            "id_resultat": Resultat._id,
            "numero_etudiant": etudiant["numero_etudiant"],
            "id_annee_formation": annee_formation["id_annee_formation"],
            "id_semestre": semestre["id_semestre"],
            "moyenne_semestre": random.uniform(0, 20),
            "moyenne_annuelle": random.uniform(0, 20),
            "mention": fake.random_element(
                elements=("AB", "B", "TB", "ADMIS", "AJOURNE")
            ),
        }
