from faker import Faker
from Inscription import Inscription
from ElementConstitutif import ElementConstitutif
import random

# Initialize Faker for generating data
fake = Faker()


class NoteEc:

    @staticmethod
    def generate(inscription: Inscription, ec: ElementConstitutif):
        inscription = inscription if inscription else Inscription.generate()
        ec = ec if ec else ElementConstitutif.generate()
        return {
            "id_inscription": inscription["id_inscription"],
            "id_ec": ec["id_ec"],
            "note": round(random.uniform(0, 20), 2),
        }
