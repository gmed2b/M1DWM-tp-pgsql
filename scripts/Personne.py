from faker import Faker

# Initialize Faker for generating data
fake = Faker()


class Personne:
    _emails = set()  # To ensure unique emails
    _telephones = set()  # To ensure unique telephone numbers
    _id = 0  # To generate unique IDs

    @staticmethod
    def generate(isMale: bool):
        Personne._id += 1

        titre = "M." if isMale else "Mme"
        while True:
            email = fake.unique.email()
            telephone = fake.unique.phone_number()
            if email not in Personne._emails:
                Personne._emails.add(email)
                break
            if telephone not in Personne._telephones:
                Personne._telephones.add(telephone)
                break

        return {
            "id_personne": Personne._id,
            "titre": titre,
            "nom": fake.last_name(),
            "prenom": fake.first_name_male() if isMale else fake.first_name_female(),
            "date_naissance": fake.date_of_birth(
                minimum_age=18, maximum_age=65
            ).strftime("%Y-%m-%d"),
            "email": email,
            "telephone": telephone,
            "adresse": fake.address(),
        }

    @staticmethod
    def generateMany(num: int):
        return [Personne.generate(fake.boolean()) for i in range(num)]
