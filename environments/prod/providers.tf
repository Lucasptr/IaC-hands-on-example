terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.56.0"
    }
  }

  backend "s3" {
    bucket       = "hands-on-s3-bucket-lpd"
    key          = "states/terraform.tfstate"
    profile      = "default"
    use_lockfile = true
    region       = "us-east-1"
    #dynamodb_table = "tf-state-locking"
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}
