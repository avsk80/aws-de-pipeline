terraform {
  backend "s3" {
    bucket         = "movie-pipeline-prod-tfstate"
    key            = "data-pipeline/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = true
    encrypt        = true
  }
}