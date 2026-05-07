variable "project_name" {
  type = string
}

variable "environment" {
  type = string
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

variable "lambda_handler" {
  type    = string
  default = "src/handler.lambda_handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.11"
}

variable "lambda_memory_size" {
  type = number
}

variable "lambda_timeout" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}