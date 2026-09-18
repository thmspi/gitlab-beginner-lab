# Ressources fournies

Ces fichiers sont prêts à l'emploi. L'étudiant construit la pipeline GitLab ; il n'a pas à inventer le code Python ou Terraform.

```text
ressources/
├── README.md
├── pytest.ini
├── requirements-dev.txt
├── src/
│   ├── __init__.py
│   └── lambda_function.py
├── tests/
│   └── test_lambda.py
└── terraform/
    ├── backend.tf
    ├── versions.tf
    ├── provider.tf
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

La Lambda retourne `Hello <name>!`. Les deux tests utilisent pytest. Ruff contrôle le style, Bandit effectue une analyse de sécurité simple et Terraform crée uniquement un rôle IAM et une fonction Lambda.

Le backend Terraform est **S3**, avec le locking natif `use_lockfile = true`. Aucun backend GitLab n'est configuré.
