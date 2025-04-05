variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub owner/organization"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key ID for GitHub Actions"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for GitHub Actions"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for Medusa"
  type        = string
  sensitive   = true
}

variable "cookie_secret" {
  description = "Cookie secret for Medusa"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "medusa"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "medusa"
}

variable "store_cors" {
  description = "Store CORS configuration"
  type        = string
  default     = "http://localhost:8000,http://localhost:7001"
}

variable "admin_cors" {
  description = "Admin CORS configuration"
  type        = string
  default     = "http://localhost:7000,http://localhost:7001"
}

variable "medusa_bucket_name" {
  description = "Name of the S3 bucket for Medusa storage"
  type        = string
}
