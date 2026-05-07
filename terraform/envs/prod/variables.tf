variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "create_cloudwatch_logs_endpoint" {
  type    = bool
  default = false
}

variable "raw_bucket_name" {
  type = string
}

variable "processed_bucket_name" {
  type = string
}

variable "lambda_package_path" {
  type = string
}

variable "lambda_memory_size" {
  type = number
}

variable "lambda_timeout" {
  type = number
}