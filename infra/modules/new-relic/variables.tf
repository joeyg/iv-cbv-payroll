variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "newrelic_account_id" {
  type        = string
  description = "New Relic account ID for external ID in IAM role"
}