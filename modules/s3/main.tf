resource "aws_s3_bucket" "mybucket" {
  bucket = "acme-inc-bucket-0318"

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Prod"
  }

}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "example" {
  description             = "An example symmetric encryption KMS key"
  deletion_window_in_days = 20
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.example.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    id = "Allow small object transitions"

    filter {}
    

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER_IR"
    }
  }
}