terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }

backend "s3" {
  bucket = "jenkins-tf-remote-state"
  key = "jenkins-tf-tools"
  region = "us-east-1"
  dynamodb_table="jenkins-tf-locking"
  }
}
#provide authentication here
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

