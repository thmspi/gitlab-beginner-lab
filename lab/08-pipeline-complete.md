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

## Validation finale

Montrez dans GitLab :

1. les trois jobs du stage `test` ;
2. l'artifact `lambda.zip` ;
3. le plan Terraform conservé ;
4. la gate manuelle de déploiement ;
5. une pipeline normale sans job destructif ;
6. une pipeline lancée avec `ALLOW_DESTROY=true` ;
7. le nettoyage AWS réussi.

Le workshop est terminé lorsque la Lambda, son rôle IAM et le bucket S3 du lab ont été supprimés.

[Retour au sommaire](README.md)
