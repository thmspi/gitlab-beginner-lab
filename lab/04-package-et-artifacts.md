# Chapitre 4 — Packager la Lambda et conserver un artifact

## Contexte

AWS Lambda attend une archive ZIP. Le disque d'un runner n'est pas partagé durablement avec les jobs suivants.

## Objectif

Produire `lambda.zip` dans un stage `package` et demander à GitLab de le conserver.

## Commandes fournies

Utilisez l'image `alpine:3.22` :

```bash
apk add --no-cache zip
zip -j lambda.zip ressources/src/lambda_function.py
```

L'option `-j` place directement `lambda_function.py` à la racine du ZIP, comme l'attend le handler Terraform.

## À vous de jouer

Ajoutez `package` après `test` dans `stages`. Créez `package_lambda`, puis conservez le ZIP pendant un jour :

```yaml
artifacts:
  paths:
    - lambda.zip
  expire_in: 1 day
```

## Vérification

Committez et poussez avec `ci: packager la Lambda`. Le job doit démarrer seulement après la réussite du stage `test`.

Ouvrez `package_lambda`, puis **Job artifacts > Browse**. `lambda.zip` doit contenir directement `lambda_function.py`. L'artifact est la copie conservée par GitLab après la fin du job.

[Chapitre suivant : plan Terraform](05-terraform-plan.md)
