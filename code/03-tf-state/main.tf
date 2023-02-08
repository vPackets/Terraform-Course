terraform {
  required_version = ">1.0.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket  = "vpackets-s3-bucket"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-2"
    profile = "vPackets"

    dynamodb_table = "vpackets-tf-table"
    encrypt        = true
  }
}


provider "aws" {
    region = "us-east-2"
    profile = "vPackets"
}


####### S3 Bucket Provisioning #######
resource "aws_s3_bucket" "vpackets_tf_state" {
    bucket = var.bucket_name
    force_destroy = true
}

####### S3 Bucket Configuration : Versioning #######

resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.vpackets_tf_state.id

    versioning_configuration {
        status = "Enabled"
    }
}

####### S3 Bucket Configuration : Encryption #######

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
    bucket = aws_s3_bucket.vpackets_tf_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

####### S3 Bucket Configuration : Restrict Public access #######

resource "aws_s3_bucket_public_access_block" "private_access" {
    bucket = aws_s3_bucket.vpackets_tf_state.id
    block_public_acls       = true
    block_public_policy     =  true
    ignore_public_acls      =  true
    restrict_public_buckets = true
}

####### DynamoDB Table Provisionning : Versioning #######

resource "aws_dynamodb_table" "basic_dynamodb_table" {
  name           = var.database_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}





resource "aws_instance" "vPackets_ec2" {
  ami           = "ami-0ab0629dba5ae551d" # us-west-2
  instance_type = "t2.micro"

  tags = {
    name = "vPackets - EC2"
  }
}
