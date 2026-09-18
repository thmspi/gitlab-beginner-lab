# Chapitre 2 — Ajouter les stages et les tests

## Contexte

Afficher une version ne valide pas la Lambda. Les tests sont déjà fournis dans `ressources/tests/test_lambda.py`.

## Objectif

Remplacer `hello_ci` par `unit_tests`, placé dans le stage `test`, puis observer un échec contrôlé.

## Commandes fournies

```bash
pip install pytest==8.4.2
pytest -c ressources/pytest.ini
```

Le fichier `ressources/pytest.ini` indique à pytest où trouver le code et les tests.

## À vous de jouer

Déclarez d'abord le stage :

```yaml
stages:
  - test
```

Créez le job `unit_tests` avec l'image `python:3.13-slim` :

- placez l'installation de pytest dans `before_script` ;
- placez son exécution dans `script` ;
- affectez le job au stage `test`.

## Vérification

Committez et poussez avec le message `ci: executer les tests unitaires`. Le job doit afficher `2 passed`.

Dans `ressources/tests/test_lambda.py`, remplacez temporairement `Hello Ada!` par `Hello Bob!`, puis committez. Pytest retourne un code non nul : le job et la pipeline échouent. Rétablissez ensuite `Hello Ada!`, committez et vérifiez que la pipeline repasse au vert.

[Chapitre suivant : lint et sécurité](03-lint-et-securite.md)
