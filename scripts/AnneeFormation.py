from faker import Faker
from Formation import Formation

# Initialize Faker for generating data
fake = Faker()


class AnneeFormation:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generateMany(formation: Formation):
        formation = formation if formation else Formation.generate()
        annees = []
        if formation["niveau"] == "Licence":
            for niveau in ["Licence 1", "Licence 2", "Licence 3"]:
                annees.append(AnneeFormation.generateAnnee(formation, niveau))
        elif formation["niveau"] == "Master":
            for niveau in ["Master 1", "Master 2"]:
                annees.append(AnneeFormation.generateAnnee(formation, niveau))

        return annees

    @staticmethod
    def generateAnnee(formation: Formation, niveau: str):
        AnneeFormation._id += 1
        return {
            "id_annee_formation": AnneeFormation._id,
            "id_formation": formation["id_formation"],
            "date_formation": fake.date_between(start_date="-20y", end_date="now"),
            "niveau": niveau,
            "nbr_max_etu": fake.random_int(min=10, max=100),
        }
