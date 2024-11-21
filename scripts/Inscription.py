from faker import Faker
from Etudiant import Etudiant
from AnneeFormation import AnneeFormation
import datetime

# Initialize Faker for generating data
fake = Faker()


class Inscription:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate(etudiant: Etudiant, annee_formation: AnneeFormation):
        Inscription._id += 1
        etudiant = etudiant if etudiant else Etudiant.generate()
        annee_formation = (
            annee_formation if annee_formation else AnneeFormation.generate()
        )

        annee = annee_formation["date_formation"].year
        # date inscription is same year as date formation but before start of formation
        date_inscription = fake.date_between_dates(
            date_start=datetime.date(annee, 6, 1),
            date_end=datetime.date(annee, 9, 30),
        )

        # var: valide_le is a date value set if year is not current year and date after end of formation else is None
        valide_le = (
            fake.date_between_dates(
                date_start=datetime.date(annee + 1, 5, 31),
                date_end=datetime.date(annee + 1, 6, 30),
            )
            if annee != datetime.date.today().year
            else None
        )

        return {
            "id_inscription": Inscription._id,
            "numero_etudiant": etudiant["numero_etudiant"],
            "id_annee_formation": annee_formation["id_annee_formation"],
            "date_inscription": date_inscription.strftime("%Y-%m-%d"),
            "valide_le": valide_le.strftime("%Y-%m-%d") if valide_le else None,
            "mention": (
                fake.random_element(elements=("AB", "B", "TB", "ADMIS", "AJOURNE"))
                if valide_le
                else None
            ),
        }
