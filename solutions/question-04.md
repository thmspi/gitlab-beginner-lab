# Solution 4 — Package et artifact

```yaml
stages:
  - test
  - package

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

package_lambda:
  stage: package
  image: alpine:3.22
  before_script:
    - apk add --no-cache zip
  script:
    - zip -j lambda.zip ressources/src/lambda_function.py
  artifacts:
    paths:
      - lambda.zip
    expire_in: 1 day
```

GitLab conserve `lambda.zip` après la fin du job et le rend disponible aux jobs suivants.
