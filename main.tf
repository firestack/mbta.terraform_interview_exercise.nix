terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.0"
   }
   archive = {
     source = "hashicorp/archive"
     version = "~> 2.0"
   }
 }
}

provider "aws" {

  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda = "http://localhost:4566"
    iam    = "http://localhost:4566"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./lambda/handler.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "hello_world"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "handler.hello_world"

  # source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

}

resource "aws_lambda_function_url" "test_latest" {
  function_name      = aws_lambda_function.test_lambda.function_name
  authorization_type = "NONE"
}
