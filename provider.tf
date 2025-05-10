terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }

backend "s3" {
  bucket = "tf-aws-tools-jenkins-remote-state"
  key = "tf-aws-tools-jenkins-Tools"
  region = "us-east-1"
  dynamodb_table="tf-aws-tools-jenkins-locking"
  }
}
#provide authentication here
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

