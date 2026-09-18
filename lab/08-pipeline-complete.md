# Chapitre 8 — Relire la pipeline complète

Vous avez construit la chaîne suivante :

```text
Push
  │
  ▼
TEST
├── unit_tests
├── lint
└── security
       │
       ▼
PACKAGE
└── package_lambda
       │ lambda.zip
       ▼
PLAN
└── terraform_plan
       │ tfplan + .terraform.lock.hcl
       ▼
DEPLOY
└── terraform_apply ▶  MANUAL / BLOCKING
       │
       ▼
AWS Lambda

Si ALLOW_DESTROY=true :

DESTROY
└── terraform_destroy ▶  MANUAL
```

## Bilan

- Un **job** exécute des commandes ; un **stage** ordonne un groupe de jobs.
- Les jobs d'un même stage peuvent s'exécuter en parallèle.
- Une **image** fournit les outils disponibles dans un job.
- `before_script` prépare l'environnement ; `script` porte le travail principal.
- Un exit code non nul fait échouer un job obligatoire et bloque les stages suivants.
- Un **artifact** conserve un fichier produit après la fin du job.
- `dependencies` choisit les artifacts des jobs précédents à télécharger.
- Les variables fournissent des valeurs ; `rules` décide de la présence d'un job.
- `when: manual` impose une action humaine et `allow_failure: false` rend cette gate bloquante.
- Le state Terraform et son verrou sont stockés dans S3, car le disque d'un runner est temporaire.

## Nettoyage final

Le job construit au chapitre 7 supprime uniquement les ressources suivies par Terraform : la Lambda et son rôle IAM. Le bucket S3 n'est pas déclaré dans Terraform et reste disponible après ce job. Conservez-le au moins jusqu'à la vérification du state final.

Vérifiez que votre `.gitlab-ci.yml` contient ce job :

```yaml
terraform_destroy:
  stage: destroy
  image:
    name: hashicorp/terraform:1.13.5
    entrypoint: [""]
  dependencies:
    - package_lambda
    - terraform_plan
  before_script:
    - >-
      terraform -chdir=ressources/terraform init -input=false -lockfile=readonly
      -backend-config="bucket=$TF_STATE_BUCKET"
      -backend-config="key=gitlab/$CI_PROJECT_ID/terraform.tfstate"
  script:
    - terraform -chdir=ressources/terraform destroy -input=false -auto-approve
  rules:
    - if: '$ALLOW_DESTROY == "true"'
      when: manual
  allow_failure: false
```

Lancez une nouvelle pipeline avec `ALLOW_DESTROY=true`. Après la réussite de `terraform_apply`, déclenchez manuellement `terraform_destroy`. Le job doit terminer par `Destroy complete! Resources: 2 destroyed.`

Dans AWS CloudShell, vérifiez que la Lambda et le rôle IAM n'existent plus, puis que le bucket existe toujours :

```bash
export LAB_FUNCTION_NAME="gitlab-lab-<ID-PROJET>"
export TF_STATE_BUCKET="<NOM-DU-BUCKET>"

aws lambda get-function \
  --function-name "$LAB_FUNCTION_NAME" \
  --region eu-west-3

aws iam get-role --role-name "${LAB_FUNCTION_NAME}-role"

aws s3api head-bucket --bucket "$TF_STATE_BUCKET"
```

Les deux premières commandes doivent retourner respectivement `ResourceNotFoundException` et `NoSuchEntity`. Une erreur `AccessDenied` ne prouve pas la suppression. La commande `head-bucket` doit réussir : à ce point du nettoyage, le bucket S3 et son contenu sont conservés. Il s'agit de la seule ressource AWS du lab encore présente.

### Optionnel — supprimer aussi le bucket du state

Effectuez cette étape uniquement si le state Terraform ne sera plus jamais utilisé. Le bucket est versionné : `aws s3 rm --recursive` ne suffit pas, car il ne supprime pas définitivement les anciennes versions et les marqueurs de suppression.

Dans AWS CloudShell, vérifiez la valeur de `TF_STATE_BUCKET`, puis exécutez :

```bash
cleanup_state_bucket() {
  local confirm_bucket versions_json delete_payload delete_count

  if [[ -z "${TF_STATE_BUCKET:-}" || "$TF_STATE_BUCKET" != *-gitlab-tfstate ]]; then
    echo "Nom de bucket absent ou inattendu : arrêt."
    return 1
  fi

  read -r -p "Tapez le nom du bucket à supprimer définitivement : " confirm_bucket
  if [[ "$confirm_bucket" != "$TF_STATE_BUCKET" ]]; then
    echo "Confirmation incorrecte : arrêt."
    return 1
  fi

  while true; do
    versions_json="$(
      aws s3api list-object-versions \
        --bucket "$TF_STATE_BUCKET" \
        --max-items 1000 \
        --output json
    )" || return 1

    delete_payload="$(
      jq -c '{
          Objects: (((.Versions // []) + (.DeleteMarkers // []))
            | map({Key: .Key, VersionId: .VersionId})),
          Quiet: true
        }' <<< "$versions_json"
    )" || return 1

    delete_count="$(jq '.Objects | length' <<< "$delete_payload")" || return 1
    [[ "$delete_count" -eq 0 ]] && break

    aws s3api delete-objects \
      --bucket "$TF_STATE_BUCKET" \
      --delete "$delete_payload" || return 1
  done

  aws s3api delete-bucket \
    --bucket "$TF_STATE_BUCKET" \
    --region eu-west-3
}

cleanup_state_bucket
unset -f cleanup_state_bucket
```

La boucle traite au maximum 1 000 versions ou marqueurs à la fois, puis recommence jusqu'à ce que le bucket soit vide. La dernière commande supprime le bucket. Cette suppression est définitive.

Enfin, dans **Settings > CI/CD > Variables**, supprimez les variables temporaires du projet :

- `AWS_ACCESS_KEY_ID` ;
- `AWS_SECRET_ACCESS_KEY` ;
- `AWS_SESSION_TOKEN`, si elle a été créée ;
- `AWS_DEFAULT_REGION` ;
- `TF_STATE_BUCKET`.

Effectuez ce nettoyage seulement après la réussite de `terraform_destroy`, car ce job utilise encore ces variables. La valeur `ALLOW_DESTROY=true` ajoutée lors du lancement est limitée à cette pipeline et n'apparaît pas dans les variables persistantes du projet.

## Validation finale

Montrez dans GitLab :

1. les trois jobs du stage `test` ;
2. l'artifact `lambda.zip` ;
3. le plan Terraform conservé ;
4. la gate manuelle de déploiement ;
5. une pipeline normale sans job destructif ;
6. une pipeline lancée avec `ALLOW_DESTROY=true` ;
7. le nettoyage AWS réussi, avec uniquement le bucket S3 conservé avant son éventuelle suppression ;
8. l'absence des variables temporaires dans les réglages CI/CD du projet.

Le workshop est terminé lorsque la Lambda et son rôle IAM ont été supprimés et que les variables temporaires ont été retirées de GitLab. Le bucket et son state peuvent être conservés, ou supprimés définitivement avec l'étape optionnelle ci-dessus.

[Retour au sommaire](README.md)
