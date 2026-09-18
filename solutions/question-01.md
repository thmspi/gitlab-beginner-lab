# Solution 1 — Première pipeline

```yaml
hello_ci:
  image: python:3.13-slim
  script:
    - python --version
```

Le runner lance `python --version` dans l'image demandée. L'exit code `0` produit un job réussi.
