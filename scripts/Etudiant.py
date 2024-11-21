from faker import Faker
from Personne import Personne
import datetime

# Initialize Faker for generating data
fake = Faker()


class Etudiant:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate():
        Etudiant._id += 1
        personne = Personne.generate(fake.boolean())
        return {
            "numero_etudiant": Etudiant._id,
            "id_personne": personne["id_personne"],
            "email_etudiant": personne["email"],
            "personne": personne,
        }

    @staticmethod
    def generateMany(num: int):
        return [Etudiant.generate() for i in range(num)]
