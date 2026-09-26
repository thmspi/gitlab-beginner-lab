# Chapitre 7 — Protéger la destruction

## Contexte

`terraform destroy` est destructif. Le job ne doit même pas être proposé dans une pipeline ordinaire.

## Objectif

Créer un job absent par défaut et visible uniquement avec `ALLOW_DESTROY=true`. Lorsqu'il est présent, il doit être disponible immédiatement, sans attendre les jobs précédents. Son exécution réelle aura lieu pendant le nettoyage final du chapitre 8.

## Commandes fournies

Complétez le bloc global `variables` existant :

```yaml
variables:
  TF_VAR_function_name: "gitlab-lab-${CI_PROJECT_ID}"
  ALLOW_DESTROY: "false"
```

Utilisez la même image Terraform et ces commandes :

```bash
terraform -chdir=ressources/terraform init -input=false \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=gitlab/$CI_PROJECT_ID/terraform.tfstate"

terraform -chdir=ressources/terraform destroy -input=false -auto-approve
```

## À vous de jouer

Ajoutez `destroy` après `deploy`. Le job récupère directement le state dans S3 et ne télécharge aucun artifact de `package_lambda` ou `terraform_plan`.

Pour le rendre disponible dès la création de la pipeline, sans attendre les stages précédents, ajoutez :

```yaml
needs: []
```

Un tableau `needs` vide indique que le job n'a aucune dépendance d'exécution. Il reste manuel : `needs: []` permet de le lancer immédiatement, mais ne déclenche pas la destruction automatiquement.

Comme le job ne télécharge pas `.terraform.lock.hcl`, sa commande `terraform init` n'utilise pas `-lockfile=readonly` et crée son propre lock file local. La version du provider reste fixée dans `versions.tf`. La configuration Terraform fournie tolère également l'absence de `lambda.zip` pendant le calcul du plan de destruction.

Contrôlez sa présence avec :

```yaml
rules:
  - if: '$ALLOW_DESTROY == "true"'
    when: manual
```

Ajoutez `allow_failure: false`. Les quatre mécanismes ont des rôles distincts :

```text
variables    → fournir une valeur
rules        → décider si le job existe
when: manual → attendre le déclenchement humain
needs: []    → ne pas attendre les stages précédents
```

## Vérification du comportement par défaut

Committez et poussez avec `ci: ajouter un nettoyage protege`.

`terraform_destroy` doit être absent de la pipeline. Vous pouvez annuler cette pipeline après ce contrôle afin de ne pas préparer un nouveau déploiement.

## Vérifier la présence du job

1. Ouvrez **Build > Pipelines > New pipeline**.
2. Sélectionnez la branche contenant le lab.
3. Ajoutez la variable `ALLOW_DESTROY` avec la valeur `true` pour cette exécution.
4. Lancez la pipeline : `terraform_destroy` doit apparaître immédiatement, sans attendre `package_lambda`, `terraform_plan` ou `terraform_apply`.
5. Ne déclenchez pas encore le job : le chapitre 8 exécute le nettoyage et vérifie son résultat.

Le bucket a été créé hors de Terraform : `terraform_destroy` ne le supprimera pas. Ne le videz pas et ne le supprimez pas à ce stade. Le chapitre 8 permet de vérifier que lui seul reste présent, puis propose sa suppression définitive en option.

[Chapitre suivant : relire la pipeline](08-pipeline-complete.md)
