project_name = "movie-pipeline"
environment  = "qa"
aws_region   = "us-east-1"

vpc_cidr = "10.20.0.0/16"

private_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

create_cloudwatch_logs_endpoint = false

raw_bucket_name       = "movie-pipeline-qa-raw"
processed_bucket_name = "movie-pipeline-qa-processed"

lambda_package_path = "../../../lambda-package.zip"
lambda_memory_size  = 512
lambda_timeout      = 60