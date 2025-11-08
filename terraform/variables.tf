#############################
# Lambda Configuration
#############################

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "SpringBootLambdaFunction"
}

variable "lambda_handler" {
  description = "Fully qualified handler class for the Lambda function"
  type        = string
  default     = "com.singh.StreamLambdaHandler::handleRequest"
}

variable "lambda_runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "java21"
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda function (MB)"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout (seconds)"
  type        = number
  default     = 30
}

variable "lambda_jar_path" {
  description = "Path to the shaded JAR file to deploy"
  type        = string
  default     = "../target/springboot-aws-lambda-api-gateway-1.0-SNAPSHOT.zip"
}

variable "lambda_s3_key" {
  description = "Name of the JAR object in S3"
  type        = string
  default     = "springboot-aws-lambda-api-gateway-1.0-SNAPSHOT.zip"
}

#############################
# API Gateway Configuration
#############################

variable "api_gateway_name" {
  description = "API Gateway name"
  type        = string
  default     = "SpringBootLambdaApi"
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

#############################
# AWS Configuration
#############################

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}