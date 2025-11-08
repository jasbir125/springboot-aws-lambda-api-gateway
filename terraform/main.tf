# ---------------------------------
# IAM Role for Lambda
# ---------------------------------
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ---------------------------------
# Local Variables
# ---------------------------------
locals {
  jar_path = var.lambda_jar_path
}

# ---------------------------------
# Random ID for S3 bucket
# ---------------------------------
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ---------------------------------
# S3 bucket and object
# ---------------------------------
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-artifacts-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_object" "lambda_jar" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = var.lambda_s3_key
  source = local.jar_path
  etag   = filemd5(local.jar_path)
}

# ---------------------------------
# IAM Policy Attachment
# ---------------------------------
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ---------------------------------
# Lambda Function
# ---------------------------------
resource "aws_lambda_function" "spring_boot_lambda" {
  function_name = var.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_exec_role.arn

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_jar.key

  source_code_hash = filebase64sha256(var.lambda_jar_path)

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  depends_on = [aws_s3_object.lambda_jar]
}

# ---------------------------------
# API Gateway
# ---------------------------------
resource "aws_api_gateway_rest_api" "spring_boot_lambda_api" {
  name = var.api_gateway_name
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.spring_boot_lambda_api.id
  parent_id   = aws_api_gateway_rest_api.spring_boot_lambda_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.spring_boot_lambda_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.spring_boot_lambda_api.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.spring_boot_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.spring_boot_lambda_api.id
}

resource "aws_api_gateway_stage" "prod_stage" {
  rest_api_id   = aws_api_gateway_rest_api.spring_boot_lambda_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = var.api_stage_name
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spring_boot_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.spring_boot_lambda_api.execution_arn}/*/*"
}

# ---------------------------------
# Output
# ---------------------------------
output "spring_boot_lambda_api_url_localstack" {
  description = "Invoke URL for Spring Boot Lambda via API Gateway (LocalStack or aws)"
  #value       = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.spring_boot_lambda_api.id}/${var.api_stage_name}/_user_request_/"
  value =  "https://${aws_api_gateway_rest_api.spring_boot_lambda_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.api_stage_name}/"

}