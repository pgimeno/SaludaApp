terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "saludaapp-terraform-state-245324546838"
    key          = "saludaapp/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

# Rol existente proporcionado por el laboratorio
data "aws_iam_role" "lambda_role" {
  name = "studentLambdaExecutionRole"
}

resource "aws_lambda_function" "saluda_app" {
  function_name = "saluda-app"

  role = data.aws_iam_role.lambda_role.arn

  runtime = "dotnet8"

  handler = "SaludaApp"

  filename         = "${path.module}/../publish/saluda-app.zip"
  source_code_hash = filebase64sha256("${path.module}/../publish/saluda-app.zip")

  memory_size = 512
  timeout     = 30
}

resource "aws_apigatewayv2_api" "api" {
  name          = "saluda-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.api.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.saluda_app.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "saludo" {
  api_id = aws_apigatewayv2_api.api.id

  route_key = "GET /saludo"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id = aws_apigatewayv2_api.api.id

  name        = "prod"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.saluda_app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}