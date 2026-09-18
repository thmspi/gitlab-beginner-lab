terraform {
  backend "s3" {
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
