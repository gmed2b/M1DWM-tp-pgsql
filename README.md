# M1DWM-tp-pgsql

## Installation

### Configuration de l'environnement virtuel Python

1. Assurez-vous d'avoir Python installé sur votre machine. Vous pouvez le télécharger depuis [python.org](https://www.python.org/).

2. Créez un environnement virtuel :

```bash
python -m venv .venv
```

3. Activez l'environnement virtuel :

- Sur macOS/Linux :
  ```bash
  source .venv/bin/activate
  ```
- Sur Windows :
  ```bash
  .\venv\Scripts\activate
  ```

4. Installez les dépendances requises à partir du fichier `requirements.txt` :

```bash
pip install -r requirements.txt
```

### Lancement du script de peuplement

1. Assurez-vous que l'environnement virtuel est activé.

2. Exécutez le script de generation de peuplement :

```bash
python scripts/generate-seed.py
```
