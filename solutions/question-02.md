# Solution 2 — Stages et tests

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
```

`before_script` installe l'outil dans le conteneur du job. Pytest retourne un code non nul lorsqu'un test échoue.
