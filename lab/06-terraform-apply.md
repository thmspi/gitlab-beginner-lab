# Chapitre 6 — Déployer derrière une gate manuelle

## Contexte

Un plan réussi n'est pas une autorisation de déployer. Une personne doit lire les changements avant leur application.

## Objectif

Créer `terraform_apply` dans le stage `deploy`, avec une validation manuelle bloquante, puis invoquer la Lambda.

## Commandes fournies

Utilisez la même image Terraform qu'au chapitre précédent :

```bash
terraform -chdir=ressources/terraform init -input=false -lockfile=readonly \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=gitlab/$CI_PROJECT_ID/terraform.tfstate"

terraform -chdir=ressources/terraform apply -input=false tfplan
```

`init` va dans `before_script`. `apply` va dans `script`.

## À vous de jouer

Ajoutez `deploy` après `plan`. Créez `terraform_apply` avec :

```yaml
dependencies:
  - terraform_plan
  - package_lambda
```

Le job de plan apporte `tfplan` et `.terraform.lock.hcl`. Le job de package apporte `lambda.zip`, que Terraform doit envoyer à AWS. Les artifacts ne sont pas transmis de manière transitive.

Rendez le job manuel et bloquant :

```yaml
when: manual
allow_failure: false
```

Cette combinaison forme une gate : la pipeline attend le clic puis la réussite du job.

## Vérification

Committez et poussez avec `ci: ajouter le deploiement manuel`.

Après le plan, la pipeline doit afficher le statut **blocked** et un bouton ▶ pour `terraform_apply`. Lisez le plan, lancez le job et attendez `Apply complete!`.

Dans AWS CloudShell, remplacez `<ID-PROJET>` par l'identifiant numérique visible dans le nom de la fonction :

```bash
export LAB_FUNCTION_NAME="gitlab-lab-<ID-PROJET>"

aws lambda wait function-active-v2 \
  --function-name "$LAB_FUNCTION_NAME" \
  --region eu-west-3

aws lambda invoke \
  --function-name "$LAB_FUNCTION_NAME" \
  --region eu-west-3 \
  --cli-binary-format raw-in-base64-out \
  --payload '{"name":"GitLab"}' \
  response.json

cat response.json
```

La réponse attendue est `{"statusCode": 200, "body": "Hello GitLab!"}`.

[Chapitre suivant : destruction protégée](07-destroy-protege.md)
