terraform {
  backend "s3" {
    bucket         = "prizedly-terraform-state"
    key            = "env/staging/staging.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "prizedly-staging-terraform-state-lock"
  }
}
