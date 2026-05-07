terraform {
  backend "s3" {
    bucket         = "movie-pipeline-qa-tfstate"
    key            = "data-pipeline/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = true
    encrypt        = true
  }
}