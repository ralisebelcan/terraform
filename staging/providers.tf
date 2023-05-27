##################
# Providers
##################
terraform {
  required_version = ">= 1.1.9"
  required_providers {
    aws = {
      version = "4.12.1"
    }
    random = {
      version = "~> 2.1"
    }
  }
}


provider "aws" {
  region = "eu-north-1"
}

provider "random" {
}

provider "local" {
}

provider "null" {
}
