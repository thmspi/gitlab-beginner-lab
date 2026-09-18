# Lab — Construire une pipeline GitLab CI/CD

Vous rejoignez une équipe qui teste, analyse et déploie encore sa Lambda à la main. Chaque chapitre résout un problème de cette chaîne et introduit une notion GitLab CI/CD.

Essayez chaque exercice avant de consulter un corrigé auprès de l'animateur. Les commandes Python, Terraform et AWS sont toujours fournies : votre travail porte sur la construction de la pipeline.

## Parcours

0. [Préparer GitLab et AWS](00-preparer-environnement.md)
1. [Créer une première pipeline](01-premiere-pipeline.md)
2. [Ajouter les stages et les tests](02-stages-et-tests.md)
3. [Ajouter le lint et la sécurité](03-lint-et-securite.md)
4. [Packager la Lambda et conserver un artifact](04-package-et-artifacts.md)
5. [Créer un plan Terraform et utiliser dependencies](05-terraform-plan.md)
6. [Déployer derrière une gate manuelle](06-terraform-apply.md)
7. [Protéger la destruction avec une variable](07-destroy-protege.md)
8. [Relire la pipeline complète](08-pipeline-complete.md)

## Règles du workshop

- Travaillez dans `.gitlab-ci.yml`, à la racine du projet.
- Utilisez uniquement les notions introduites dans le chapitre courant.
- Attendez la fin d'une pipeline avant de modifier la même infrastructure.
- Supprimez les ressources AWS au chapitre 7.

Le workshop n'utilise ni `workflow`, ni `needs`, ni cache, ni templates, ni Docker-in-Docker. Le state Terraform utilise exclusivement le backend S3 fourni dans `ressources/terraform/backend.tf`.
