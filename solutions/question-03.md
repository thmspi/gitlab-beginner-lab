# Solution 3 — Lint et sécurité

```yaml
stages:
  - test

unit_tests:
  stage: test
  image: python:3.13-slim
  before_script:
    - pip install pytest==8.4.2
  script:
    - pytest -c ressources/pytest.ini

lint:
  stage: test
  image: python:3.13-slim
  before_script:
    - pip install ruff==0.14.4
  script:
    - ruff check ressources/
    - ruff format --check ressources/

security:
  stage: test
  image: python:3.13-slim
  before_script:
    - pip install bandit==1.8.6
  script:
    - bandit -r ressources/src/
```

Les trois jobs sont indépendants et appartiennent au même stage. Ils peuvent donc être pris en charge en parallèle par des runners disponibles.
