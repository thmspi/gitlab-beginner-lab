# Chapitre 3 — Ajouter lint et sécurité

## Contexte

Les tests peuvent réussir malgré un style incohérent ou une construction risquée. Nous ajoutons deux contrôles indépendants dans le même stage.

## Objectif

Obtenir trois jobs dans `test` : `unit_tests`, `lint` et `security`.

## Commandes fournies

Pour `lint`, avec `python:3.13-slim` :

```bash
pip install ruff==0.14.4
ruff check ressources/
ruff format --check ressources/
```

Pour `security`, avec la même image :

```bash
pip install bandit==1.8.6
bandit -r ressources/src/
```

## À vous de jouer

Conservez `unit_tests`. Ajoutez `lint` et `security` dans le stage `test`, avec l'installation dans `before_script` et les contrôles dans `script`.

## Vérification

Committez et poussez avec le message `ci: ajouter lint et securite`.

`unit_tests` et `security` doivent réussir. `lint` doit échouer sur le contrôle de formatage : le starter contient volontairement des guillemets simples dans `ressources/src/lambda_function.py`.

Corrigez cette ligne dans Visual Studio Code ou dans votre éditeur :

```python
    name = event.get("name", "GitLab")
```

Committez avec `style: corriger le formatage Python`. Les trois jobs doivent réussir. Comme ils appartiennent au même stage, ils peuvent s'exécuter en parallèle si des runners sont disponibles.

[Chapitre suivant : package et artifacts](04-package-et-artifacts.md)
