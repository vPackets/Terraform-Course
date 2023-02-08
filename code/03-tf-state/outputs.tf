output "s3_bucket_arn" {
  value             = aws_s3_bucket.vpackets_tf_state.arn
  description       = "This is the ARN of the S3 bucket"
}


output "dynamo_db_table_name" {
    value           = aws_dynamodb_table.basic_dynamodb_table.name
    description     = "This is the name of the Dyname DB table"
}
