# Chapitre 7 — Protéger la destruction

## Contexte

`terraform destroy` est destructif. Le job ne doit même pas être proposé dans une pipeline ordinaire.

## Objectif

Créer un job absent par défaut, visible uniquement avec `ALLOW_DESTROY=true`, puis supprimer les ressources du lab.

## Commandes fournies

Complétez le bloc global `variables` existant :

```yaml
variables:
  TF_VAR_function_name: "gitlab-lab-${CI_PROJECT_ID}"
  ALLOW_DESTROY: "false"
```

Utilisez la même image Terraform et ces commandes :

```bash
terraform -chdir=ressources/terraform init -input=false -lockfile=readonly \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=gitlab/$CI_PROJECT_ID/terraform.tfstate"

terraform -chdir=ressources/terraform destroy -input=false -auto-approve
```

## À vous de jouer

Ajoutez `destroy` après `deploy`. Créez `terraform_destroy` avec les artifacts de `package_lambda` et `terraform_plan`, comme le job d'application.

Contrôlez sa présence avec :

```yaml
rules:
  - if: '$ALLOW_DESTROY == "true"'
    when: manual
```

Ajoutez `allow_failure: false`. Les trois mécanismes ont des rôles distincts :

```text
variables    → fournir une valeur
rules        → décider si le job existe
when: manual → attendre le déclenchement humain
```

## Vérification du comportement par défaut

Committez et poussez avec `ci: ajouter un nettoyage protege`.

`terraform_destroy` doit être absent de la pipeline. Attendez la gate `terraform_apply`, puis annulez cette pipeline afin de ne pas redéployer pendant ce contrôle.

## Exécuter le nettoyage

1. Ouvrez **Build > Pipelines > New pipeline**.
2. Sélectionnez la branche contenant le lab.
3. Ajoutez la variable `ALLOW_DESTROY` avec la valeur `true` pour cette exécution.
4. Lancez la pipeline : `terraform_destroy` doit maintenant apparaître.
5. Attendez le plan, lisez-le, puis lancez `terraform_apply`.
6. Après sa réussite, lancez `terraform_destroy`.

Le job doit terminer par `Destroy complete! Resources: 2 destroyed.`

Dans AWS CloudShell :

```bash
aws lambda get-function \
  --function-name "$LAB_FUNCTION_NAME" \
  --region eu-west-3

aws iam get-role --role-name "${LAB_FUNCTION_NAME}-role"
```

Les erreurs attendues sont `ResourceNotFoundException` et `NoSuchEntity`. Une erreur `AccessDenied` ne prouve pas la suppression.

Le bucket a été créé hors de Terraform. Dans la console S3, videz toutes les versions et marqueurs de suppression de **votre bucket du lab**, puis supprimez-le. Supprimez ensuite les variables AWS temporaires du projet GitLab.

[Chapitre suivant : relire la pipeline](08-pipeline-complete.md)
