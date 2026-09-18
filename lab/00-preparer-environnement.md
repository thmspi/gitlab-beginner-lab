# Chapitre 0 — Préparer GitLab et AWS

## Objectif

Partir avec un projet GitLab, un runner disponible, un bucket S3 pour le state Terraform et des credentials AWS utilisables par la pipeline.

## Prérequis

Le lab demande uniquement :

- un compte GitLab ;
- un compte AWS de formation.

Le poste du workshop doit disposer de Git et de **Visual Studio Code**, ou d'un autre éditeur de code. Les commandes AWS se lancent dans **AWS CloudShell**, qui fournit déjà AWS CLI. Terraform sera exécuté par les runners GitLab.

## Préparer le projet GitLab

1. Connectez-vous à GitLab.
2. Forkez ou importez le repository starter fourni par l'animateur dans votre espace personnel.
3. Depuis **Code > Clone**, copiez l'URL HTTPS ou SSH de votre projet.
4. Dans un terminal, remplacez le placeholder puis clonez votre projet :

   ```bash
   git clone <URL-DE-VOTRE-PROJET> gitlab-cicd-beginner-lab
   cd gitlab-cicd-beginner-lab
   git switch -c workshop
   git push -u origin workshop
   ```

5. Ouvrez le dossier `gitlab-cicd-beginner-lab` dans Visual Studio Code ou dans votre éditeur habituel.
6. Dans GitLab, repérez **Build > Pipelines**, **Build > Jobs** et **Settings > CI/CD > Variables**.
7. Dans **Settings > CI/CD > Runners**, vérifiez qu'un runner Linux acceptant les jobs sans tags est disponible. Vous n'avez pas à installer de runner.

Le starter contient `lab/` et `ressources/`, mais aucun `.gitlab-ci.yml`. Vous le créerez au chapitre 1.

## Préparer AWS dans CloudShell

Ouvrez AWS CloudShell depuis la console AWS, dans la région **Europe (Paris) — `eu-west-3`**. Vérifiez le compte utilisé :

```bash
aws sts get-caller-identity
```

Le champ `Account` doit correspondre au compte annoncé par l'animateur.

Choisissez un nom S3 globalement unique, en minuscules. Remplacez le placeholder, puis exécutez :

```bash
export TF_STATE_BUCKET="<VOTRE-NOM-UNIQUE>-gitlab-tfstate"

aws s3api create-bucket \
  --bucket "$TF_STATE_BUCKET" \
  --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3

aws s3api put-bucket-versioning \
  --bucket "$TF_STATE_BUCKET" \
  --region eu-west-3 \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket "$TF_STATE_BUCKET" \
  --region eu-west-3 \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

Vérifiez le résultat :

```bash
aws s3api get-bucket-versioning --bucket "$TF_STATE_BUCKET"
aws s3api get-public-access-block --bucket "$TF_STATE_BUCKET"
```

Le versioning protège l'historique du state. Le backend S3 fourni utilise `use_lockfile = true` : Terraform crée un objet `.tflock` pendant une opération pour empêcher deux modifications simultanées. Le state ne peut pas rester sur un runner, car son espace de travail est temporaire.

## Configurer les variables GitLab

Créez des credentials temporaires avec la méthode donnée par l'animateur. Dans **Settings > CI/CD > Variables**, ajoutez :

| Clé | Valeur | Visibilité |
| --- | --- | --- |
| `AWS_ACCESS_KEY_ID` | identifiant temporaire | Masked |
| `AWS_SECRET_ACCESS_KEY` | secret temporaire | Masked |
| `AWS_SESSION_TOKEN` | jeton temporaire, si fourni | Masked |
| `AWS_DEFAULT_REGION` | `eu-west-3` | Visible |
| `TF_STATE_BUCKET` | nom exact du bucket, sans `s3://` | Visible |

Ne cochez pas **Protect variable** pour ce lab, sauf si l'animateur vous fait travailler sur une branche protégée. Ne placez jamais de credential dans `.gitlab-ci.yml`.

Ces variables donnent aux jobs l'accès à AWS et au bucket S3. Elles ne configurent aucun backend GitLab : le state reste exclusivement dans S3.

## Vérification

- [ ] Le projet starter est visible dans votre espace GitLab.
- [ ] Le projet est cloné et ouvert dans Visual Studio Code ou dans un autre éditeur.
- [ ] La branche `workshop` existe et un runner est disponible.
- [ ] CloudShell affiche le bon compte AWS.
- [ ] Le bucket S3 existe en `eu-west-3`, avec versioning et accès public bloqué.
- [ ] Les variables AWS et `TF_STATE_BUCKET` sont enregistrées dans GitLab.

[Chapitre suivant : créer une première pipeline](01-premiere-pipeline.md)
