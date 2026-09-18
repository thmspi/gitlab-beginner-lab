# Chapitre 1 — Créer une première pipeline

## Contexte

L'équipe lance ses commandes manuellement. Nous allons vérifier que GitLab peut exécuter une première commande dans un environnement Python.

## Objectif

Créer un job `hello_ci` qui affiche la version de Python.

## Commande fournie

```bash
python --version
```

Utilisez l'image `python:3.13-slim`.

## À vous de jouer

Dans Visual Studio Code, ou dans votre éditeur, créez `.gitlab-ci.yml` à la racine du projet. Définissez un job nommé `hello_ci` avec :

- `image`, pour choisir l'environnement du job ;
- `script`, pour exécuter la commande fournie.

Utilisez des espaces pour indenter le YAML.

## Vérification

Dans le terminal intégré de votre éditeur, exécutez :

```bash
git add .gitlab-ci.yml
git commit -m "ci: ajouter une premiere pipeline"
git push
```

Ouvrez **Build > Pipelines**, puis le job `hello_ci`. Les logs doivent afficher Python 3.13 et le job doit être vert.

Le runner exécute le job dans un conteneur construit depuis l'image. Une commande qui termine avec l'exit code `0` fait réussir le job ; un code non nul le fait échouer.

[Chapitre suivant : stages et tests](02-stages-et-tests.md)
