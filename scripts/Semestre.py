from faker import Faker
from AnneeFormation import AnneeFormation
import datetime

# Initialize Faker for generating data
fake = Faker()


class Semestre:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generateMany(annee_formation: AnneeFormation):
        semestres = []
        for num_semestre in range(1, 3):
            semestre = ("Semestre " + str(num_semestre),)
            semestres.append(Semestre.generateSemestre(annee_formation, semestre))

        return semestres

    @staticmethod
    def generateSemestre(annee_formation: AnneeFormation, semestre: str):
        Semestre._id += 1
        annee_formation = (
            annee_formation if annee_formation else AnneeFormation.generate()
        )
        annee = annee_formation["date_formation"].year
        date_debut = datetime.date(annee, 9, 1)
        date_fin = datetime.date(annee + 1, 5, 31)

        return {
            "id_semestre": Semestre._id,
            "id_annee_formation": annee_formation["id_annee_formation"],
            "semestre": semestre,
            "date_debut": date_debut,
            "date_fin": date_fin,
        }
