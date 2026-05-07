project_name = "movie-pipeline"
environment  = "dev"
aws_region   = "us-east-1"

vpc_cidr = "10.10.0.0/16"

private_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

create_cloudwatch_logs_endpoint = false

raw_bucket_name       = "movie-pipeline-dev-raw"
processed_bucket_name = "movie-pipeline-dev-processed"

lambda_package_path = "../../../lambda-package.zip"
lambda_memory_size  = 512
lambda_timeout      = 60