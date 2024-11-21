from faker import Faker
from Personne import Personne

# Initialize Faker for generating data
fake = Faker()


class Enseignant:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate():
        Enseignant._id += 1
        personne = Personne.generate(fake.boolean())
        return {
            "numero_enseignant": Enseignant._id,
            "id_personne": personne["id_personne"],
            "specialite": fake.job().replace("'", ""),
            "departement": fake.random_choices(
                [
                    "Science",
                    "Lettre",
                    "Informatique",
                    "Mathematique",
                    "Economie",
                    "Physique",
                ]
            )[0],
            "personne": personne,
        }

    @staticmethod
    def generateMany(num: int):
        return [Enseignant.generate() for i in range(num)]
