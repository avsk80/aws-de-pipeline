resource "aws_s3_bucket" "raw" {
  bucket = var.raw_bucket_name

  tags = {
    Name        = var.raw_bucket_name
    Project     = var.project_name
    Environment = var.environment
    DataZone    = "raw"
  }
}

resource "aws_s3_bucket" "processed" {
  bucket = var.processed_bucket_name

  tags = {
    Name        = var.processed_bucket_name
    Project     = var.project_name
    Environment = var.environment
    DataZone    = "processed"
  }
}

resource "aws_s3_bucket_public_access_block" "raw" {
  bucket = aws_s3_bucket.raw.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "processed" {
  bucket = aws_s3_bucket.processed.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "processed" {
  bucket = aws_s3_bucket.processed.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed" {
  bucket = aws_s3_bucket.processed.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Security group for private data processing Lambda"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow HTTPS to AWS services through VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-${var.environment}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-execution-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "${var.project_name}-${var.environment}-lambda-execution-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadRawBucketObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.raw.arn}/*"
      },
      {
        Sid    = "WriteProcessedBucketObjects"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.processed.arn}/*"
      },
      {
        Sid    = "ListBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw.arn,
          aws_s3_bucket.processed.arn
        ]
      },
      {
        Sid    = "WriteCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid    = "ManageLambdaVpcEni"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}-${var.environment}-processor"

  role    = aws_iam_role.lambda_execution_role.arn
  handler = var.lambda_handler
  runtime = var.lambda_runtime

  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      RAW_BUCKET       = aws_s3_bucket.raw.bucket
      PROCESSED_BUCKET = aws_s3_bucket.processed.bucket
      ENVIRONMENT      = var.environment
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_execution_policy
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-processor"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

resource "aws_s3_bucket_notification" "raw_bucket_notification" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
    filter_suffix       = ".csv"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_to_invoke_lambda
  ]
}