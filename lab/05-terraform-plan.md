# Chapitre 5 — Créer un plan Terraform

## Contexte

Le ZIP est prêt. Avant de créer des ressources AWS, nous voulons produire un plan lisible et transmettre explicitement les fichiers nécessaires.

## Objectif

Créer `terraform_plan` dans un stage `plan`, récupérer `lambda.zip` avec `dependencies`, puis conserver `tfplan`.

## Terraform fourni

Le dossier `ressources/terraform/` contient déjà :

- le provider AWS en `eu-west-3` ;
- le backend S3 avec `use_lockfile = true` ;
- le rôle IAM assumé par Lambda ;
- la fonction Lambda Python 3.13 ;
- les variables et outputs utiles.

Le backend est exclusivement S3. Le nom du bucket et la clé sont passés à `terraform init` depuis les variables CI/CD ; aucun state GitLab n'est utilisé.

Pour tous les jobs Terraform, utilisez :

```yaml
image:
  name: hashicorp/terraform:1.13.5
  entrypoint: [""]
```

Ajoutez aussi cette variable globale au même niveau que `stages` :

```yaml
variables:
  TF_VAR_function_name: "gitlab-lab-${CI_PROJECT_ID}"
```

`CI_PROJECT_ID` est une variable prédéfinie par GitLab. Terraform lit `TF_VAR_function_name` pour nommer la Lambda de manière unique.

## Commandes fournies

```bash
terraform -chdir=ressources/terraform init -input=false \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=gitlab/$CI_PROJECT_ID/terraform.tfstate"

terraform -chdir=ressources/terraform plan -input=false -out=tfplan
```

Placez `init` dans `before_script` et `plan` dans `script`.

## À vous de jouer

Ajoutez `plan` après `package`, puis créez `terraform_plan`.

Le job doit récupérer uniquement l'artifact du package :

```yaml
dependencies:
  - package_lambda
```

Conservez pendant un jour :

```yaml
artifacts:
  paths:
    - ressources/terraform/tfplan
    - ressources/terraform/.terraform.lock.hcl
  expire_in: 1 day
```

`artifacts` décrit ce que le job produit. `dependencies` choisit les artifacts des jobs précédents qu'il télécharge. Cette sélection ne modifie pas l'ordre des stages.

## Vérification

Committez et poussez avec `ci: preparer le plan Terraform`.

Dans les logs, retrouvez le téléchargement de `lambda.zip`, l'initialisation du backend S3 et un plan annonçant au premier passage `2 to add, 0 to change, 0 to destroy`. Vérifiez la présence de `tfplan` et `.terraform.lock.hcl` dans les artifacts.

`.terraform.lock.hcl` fixe la version du provider. Le fichier `.tflock` créé temporairement dans S3 verrouille le state : ces deux fichiers ont des rôles différents.

[Chapitre suivant : déploiement manuel](06-terraform-apply.md)
