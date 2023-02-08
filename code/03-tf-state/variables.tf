variable "bucket_name" {
  description   = "This is the name given to the S3 bucket"
  type          = string
  default       = "vpackets-s3-bucket"
}

variable "database_table_name" {
    description = "This is the name given to the table"
    type        = string
    default     = "vpackets-tf-table"
}