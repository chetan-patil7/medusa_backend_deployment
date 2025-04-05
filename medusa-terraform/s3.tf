resource "aws_s3_bucket" "medusa_storage" {
  bucket = var.medusa_bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "cleanup"
    enabled = true

    expiration {
      days = 30
    }
  }

  tags = {
    Name = "Medusa Storage"
  }
}

resource "aws_s3_bucket_policy" "medusa_storage_policy" {
  bucket = aws_s3_bucket.medusa_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.medusa_storage.arn,
          "${aws_s3_bucket.medusa_storage.arn}/*"
        ]
      }
    ]
  })
}
