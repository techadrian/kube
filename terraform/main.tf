terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.91.0"
    }
  }
  backend "s3" {
      bucket         = "terraform"
      key            = "tfstate"
      region         = "eu-west-1"
      encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}


module "iam" {
  source = "./modules/iam"
  env = var.env
  sqs_queue_ids   = module.sqs.sqs_queue_ids
  lambda_role_ids = module.iam.lambda_role_ids
  dynamodb_ids    = module.dynamodb.dynamodb_ids
  common_tags     = local.common_tags

}

module "lambda" {
  source = "./modules/lambda"
  env = var.env
  lambda_role_ids = module.iam.lambda_role_ids
  sqs_queue_ids = module.sqs.sqs_queue_ids
  common_tags = local.common_tags
}


module "sqs" {
  source = "./modules/sqs"
  env = var.env
  common_tags = local.common_tags
}

module "dynamodb" {
  source = "./modules/dynamodb"
  env = var.env
  common_tags = local.common_tags
}
