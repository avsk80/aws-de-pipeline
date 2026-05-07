project_name = "movie-pipeline"
environment  = "prod"
aws_region   = "us-east-1"

vpc_cidr = "10.30.0.0/16"

private_subnet_cidrs = [
  "10.30.1.0/24",
  "10.30.2.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

create_cloudwatch_logs_endpoint = true

raw_bucket_name       = "movie-pipeline-prod-raw"
processed_bucket_name = "movie-pipeline-prod-processed"

lambda_package_path = "../../../lambda-package.zip"
lambda_memory_size  = 1024
lambda_timeout      = 120