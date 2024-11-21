import random
from faker import Faker
from UniteEnseignement import UniteEnseignement
from Enseignant import Enseignant

# Initialize Faker for generating data
fake = Faker()


class ElementConstitutif:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate(uniteEnseignement: UniteEnseignement, enseignant: Enseignant):
        ElementConstitutif._id += 1
        uniteEnseignement = (
            uniteEnseignement if uniteEnseignement else UniteEnseignement.generate()
        )
        enseignant = enseignant if enseignant else Enseignant.generate()

        return {
            "id_ec": ElementConstitutif._id,
            "id_ue": uniteEnseignement["id_ue"],
            "numero_enseignant": enseignant["numero_enseignant"],
            "nom": fake.word(),
            "heures_cours": random.randint(10, 30),
            "heures_td": random.randint(10, 30),
            "heures_tp": random.randint(10, 30),
            "modalites_evaluation": fake.text(),
        }

    @staticmethod
    def generateMany(
        num: int, uniteEnseignement: UniteEnseignement, enseignant: Enseignant
    ):
        return [
            ElementConstitutif.generate(uniteEnseignement, enseignant)
            for i in range(num)
        ]
