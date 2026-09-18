# Workshop GitLab CI/CD débutant

Ce workshop construit progressivement une pipeline GitLab CI/CD qui teste, analyse, package et déploie une AWS Lambda avec Terraform.

Le parcours dure environ **45 à 60 minutes de manipulation**. Le code est modifié dans **Visual Studio Code** ou dans un autre éditeur, et les commandes AWS sont exécutées dans AWS CloudShell.

## Prérequis

- un compte GitLab permettant de créer ou forker un projet et d'utiliser un runner ;
- un compte AWS de formation avec les permissions fournies par l'animateur.

Le poste utilisé pendant le workshop doit disposer de Git et de Visual Studio Code, ou d'un autre éditeur de code. Terraform et AWS CLI n'ont pas besoin d'être installés localement.

## Commencer le lab

Suivez les chapitres dans l'ordre depuis le [sommaire du lab](lab/README.md).

Les fichiers Python et Terraform nécessaires sont fournis dans [ressources](ressources/README.md). Ils ne demandent aucune connaissance préalable de Python ou Terraform.

```text
Push
  │
  ▼
TEST ── unit_tests, lint, security
  │
  ▼
PACKAGE ── lambda.zip
  │
  ▼
PLAN ── tfplan
  │
  ▼
DEPLOY ── validation manuelle ── AWS Lambda
  │
  ▼
DESTROY ── visible seulement avec ALLOW_DESTROY=true
```

Les corrigés destinés à l'animateur sont placés localement dans `solutions/`. Ce dossier est ignoré par Git afin que les réponses ne soient pas publiées avec le starter.
