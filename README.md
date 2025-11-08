# 🚀 Spring Boot AWS Lambda API Gateway

A **Serverless REST API** built using **Spring Boot 3**, **AWS Lambda**, and **API Gateway**, deployed with **Terraform** and tested locally using **LocalStack**.

This project demonstrates how to deploy a Java Spring Boot application as an AWS Lambda function integrated with API Gateway.

---

## 🧠 Overview

This demo showcases:
- ☁️ Serverless Spring Boot REST API running on AWS Lambda
- 🌐 API Gateway integration using Terraform
- 🧰 Local testing with LocalStack

---

## 🧩 Tech Stack
Spring Boot 3.5.7 · Java 21 · Terraform · Docker/Podman · LocalStack · AWS Lambda · API Gateway · S3

---

## ⚙️ Prerequisites

Install the following:
- Java 21
- Maven
- Terraform
- Docker or Podman
- LocalStack CLI (`pip install localstack`)

---

## 🚀 Build and Deploy

### 1️⃣ Start LocalStack
```bash
docker-compose up -d
```

### 2️⃣ Build the Application
```bash
mvn clean package
```
Generates the build at:
```
target/springboot-aws-lambda-api-gateway-1.0-SNAPSHOT.zip
```

### 3️⃣ Deploy using Terraform
```bash
tflocal init
tflocal plan -var-file="terraform.tfvars"
tflocal apply -var-file="terraform.tfvars" -auto-approve

terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
```

### 4️⃣ Test the API
Check the output URL from Terraform and invoke:
```bash
curl http://localhost:4566/restapis/<api_id>/prod/_user_request_/health
curl https://n19xfyl2d4.execute-api.ap-south-1.amazonaws.com/prod/health
```



## 🧰 Common Commands & Descriptions

| Command | Description |
|----------|--------------|
| **`mvn clean package -Pshaded-jar`** | Builds a **fat JAR** (single executable JAR) using the *shaded* profile. This includes all dependencies in one JAR, ideal for AWS Lambda deployments. |
| **`mvn clean package -Passembly-zip`** | Builds a **ZIP package** (containing compiled classes + dependencies in `/lib`) using the *assembly* profile. Useful when Lambda expects a ZIP deployment artifact. |
| **`awslocal lambda invoke --function-name SpringBootLambdaFunction out.json`** | Invokes your deployed Lambda function on **LocalStack** and writes the response to the file `out.json`. Helps verify Lambda works before API Gateway setup. |
| **`awslocal logs tail /aws/lambda/SpringBootLambdaFunction --follow`** | Streams real-time **Lambda logs** from LocalStack to your terminal, similar to `aws logs tail`. Useful for debugging function initialization and runtime errors. |
| **`tflocal init`** | Initializes the **Terraform environment** for LocalStack, downloading necessary providers and setting up the workspace. |
| **`tflocal plan -var-file="terraform.tfvars"`** | Generates and displays an **execution plan** showing which resources Terraform will create or modify in LocalStack. |
| **`tflocal apply -var-file="terraform.tfvars" -auto-approve`** | Applies the Terraform configuration and deploys all defined AWS resources (Lambda, API Gateway, S3, IAM) into LocalStack automatically without confirmation prompts. |
| **`tflocal import aws_iam_role.lambda_exec_role lambda_exec_role`** | Imports an **existing IAM role** into Terraform’s state file. Useful if the role already exists (prevents “EntityAlreadyExists” errors). |
| **`jar tf target/springboot-aws-lambda-api-gateway-1.0-SNAPSHOT.zip | grep StreamLambdaHandler`** | Lists files inside the ZIP and filters for the `StreamLambdaHandler` class to verify the **handler class is packaged correctly** for Lambda deployment. |
---

✅ **Spring Boot AWS Lambda API Gateway** running successfully on **LocalStack and AWS**!
