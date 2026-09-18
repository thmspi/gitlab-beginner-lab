# Solution 8 — Lecture de la pipeline finale

1. Un job exécute des commandes dans un environnement. Un stage regroupe des jobs à la même étape de la pipeline.
2. `unit_tests`, `lint` et `security` peuvent tourner en parallèle parce qu'ils appartiennent au même stage et n'ont pas de dépendance d'exécution entre eux.
3. `lambda.zip` est un artifact afin de survivre à la fin du runner qui l'a créé.
4. `dependencies` sélectionne les jobs précédents dont les artifacts sont téléchargés.
5. `terraform_apply` est manuel afin qu'une personne lise le plan avant de modifier AWS.
6. `allow_failure: false` rend le job obligatoire et sa réussite nécessaire à la suite de la pipeline.
7. `terraform_destroy` est absent par défaut parce que `ALLOW_DESTROY` vaut `"false"` et qu'aucune règle ne correspond.
8. `rules` décide si le job existe ; `when: manual` attend une action humaine pour le lancer.
9. Le state est enregistré dans le bucket S3, sous `gitlab/<ID-PROJET>/terraform.tfstate`.
10. Le state ne reste pas sur le runner, car son espace de travail est temporaire et peut disparaître entre deux jobs.
