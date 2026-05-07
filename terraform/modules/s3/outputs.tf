output "raw_bucket_name" {
  value = aws_s3_bucket.raw.bucket
}

output "processed_bucket_name" {
  value = aws_s3_bucket.processed.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.processor.function_name
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda.id
}