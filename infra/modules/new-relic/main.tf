data "aws_caller_identity" "current" {}

resource "aws_iam_role" "newrelic_integration" {
  name = "${var.app_name}-${var.environment}-newrelic"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::754728514883:root"
      }
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.newrelic_account_id
        }
      }
    }]
  })
}

resource "aws_iam_role" "firehose_role" {
  name = "${var.app_name}-${var.environment}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_role_policy" {
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.newrelic_backup_bucket.arn,
          "${aws_s3_bucket.newrelic_backup_bucket.arn}/*"
        ]
      },
      # allow this role to put records to any firehose stream
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "newrelic_backup_bucket" {
  bucket = "${var.app_name}-${var.environment}-newrelic-backup"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "newrelic_backup_bucket_encryption" {
  bucket = aws_s3_bucket.newrelic_backup_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "newrelic_backup_bucket_policy" {
  bucket = aws_s3_bucket.newrelic_backup_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.firehose_role.arn
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.newrelic_backup_bucket.arn,
          "${aws_s3_bucket.newrelic_backup_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "newrelic_integration_policy" {
  role = aws_iam_role.newrelic_integration.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.newrelic_backup_bucket.arn,
          "${aws_s3_bucket.newrelic_backup_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "newrelic_stream" {
  name        = "${var.app_name}-${var.environment}-newrelic-stream"
  destination = "http_endpoint"
  s3_configuration {
    role_arn           = aws_iam_role.newrelic_integration.arn
      bucket_arn         = aws_s3_bucket.newrelic_backup_bucket.arn
      buffering_size     = 10
      buffering_interval = 400
    compression_format = "GZIP"
  }
  http_endpoint_configuration {
    url                = var.newrelic_endpoint_url
    name               = "New Relic"
    access_key         = var.newrelic_license_key
    buffering_size     = 15
    buffering_interval = 600
    role_arn           = aws_iam_role.newrelic_integration.arn
    s3_backup_mode     = "FailedDataOnly"
    request_configuration {
      content_encoding = "GZIP"
    }
  }
}