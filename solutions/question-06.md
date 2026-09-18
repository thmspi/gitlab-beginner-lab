# Solution 6 — Apply manuel

```yaml
stages:
  - test
  - package
  - plan
  - deploy

variables:
  TF_VAR_function_name: "gitlab-lab-${CI_PROJECT_ID}"

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

terraform_plan:
  stage: plan
  image:
    name: hashicorp/terraform:1.13.5
    entrypoint: [""]
  dependencies:
    - package_lambda
  before_script:
    - >-
      terraform -chdir=ressources/terraform init -input=false
      -backend-config="bucket=$TF_STATE_BUCKET"
      -backend-config="key=gitlab/$CI_PROJECT_ID/terraform.tfstate"
  script:
    - terraform -chdir=ressources/terraform plan -input=false -out=tfplan
  artifacts:
    paths:
      - ressources/terraform/tfplan
      - ressources/terraform/.terraform.lock.hcl
    expire_in: 1 day

terraform_apply:
  stage: deploy
  image:
    name: hashicorp/terraform:1.13.5
    entrypoint: [""]
  dependencies:
    - terraform_plan
    - package_lambda
  before_script:
    - >-
      terraform -chdir=ressources/terraform init -input=false -lockfile=readonly
      -backend-config="bucket=$TF_STATE_BUCKET"
      -backend-config="key=gitlab/$CI_PROJECT_ID/terraform.tfstate"
  script:
    - terraform -chdir=ressources/terraform apply -input=false tfplan
  when: manual
  allow_failure: false
```

`terraform_apply` télécharge le plan, le lock file et le ZIP. Sa réussite est obligatoire : la pipeline reste bloquée tant qu'il n'est pas lancé.
