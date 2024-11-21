import random
from faker import Faker
from Semestre import Semestre

# Initialize Faker for generating data
fake = Faker()


class UniteEnseignement:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate(semestre: Semestre):
        UniteEnseignement._id += 1
        semestre = semestre if semestre else Semestre.generateSemestre()

        return {
            "id_ue": UniteEnseignement._id,
            "id_semestre": semestre["id_semestre"],
            "nom": fake.word(),
            "description": fake.text(),
            "coefficient": round(random.uniform(0, 10.0), 1),
            "obligatoire": fake.boolean(),
        }

    @staticmethod
    def generateMany(num: int, semestre: Semestre):
        return [UniteEnseignement.generate(semestre) for i in range(num)]
