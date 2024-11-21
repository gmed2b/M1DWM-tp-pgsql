from faker import Faker


# Initialize Faker for generating data
fake = Faker()

FORMATIONS_LICENCE = [
    "Science pour l''ingénieur",
    "Langues étrangères appliquées",
    "Economie et gestion",
    "Parcours accès santé",
    "Droit",
]

FORMATIONS_MASTER = [
    "Développement web mobile",
    "Data science",
    "Intelligence artificielle",
    "Marketing digital",
    "Information et communication",
    "Entrepreneuriat",
]


class Formation:
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate():
        Formation._id += 1

        niveau = fake.random_choices(
            [
                "Licence",
                "Master",
            ]
        )[0]
        departement = fake.random_choices(
            [
                "Science",
                "Lettre",
                "Informatique",
                "Mathematique",
                "Economie",
                "Physique",
            ]
        )[0]

        formation = None

        match niveau:
            case "Licence":
                formation = fake.random_choices(FORMATIONS_LICENCE)[0]
            case "Master":
                formation = fake.random_choices(FORMATIONS_MASTER)[0]

        return {
            "id_formation": Formation._id,
            "nom": formation,
            "description": fake.text(),
            "niveau": niveau,
            "departement": departement,
        }

    @staticmethod
    def generateMany(num: int):
        return [Formation.generate() for i in range(num)]
