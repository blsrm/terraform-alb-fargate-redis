variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS Access Key. e.g. Init as ENV variable TF_VAR_aws_access_key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key. e.g. Init as ENV variable TF_VAR_aws_secret_key"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "3"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "hummingbirddesign/test:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 4000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "tag_owner" {
  description = "Owner of all resources (Tag)"
  default = "hom"
}

variable "tag_usage" {
  description = "Usage of resources (Tag)"
  default = "serverless"
}

variable "project" {
  default = "Dazn"
}

variable "environment" {
  default = "Dev"
}

variable "redis_endpoint" {
  description = "Redis hostname for deno API"
  default = "dev.2pchsc.ng.0001.use1.cache.amazonaws.com"
}

