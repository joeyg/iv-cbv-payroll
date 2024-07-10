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

variable "newrelic_license_key" {
  type        = string
  description = "New Relic license key for the delivery stream"
}

variable "newrelic_endpoint_url" {
  type        = string
  description = "New Relic endpoint URL for the delivery stream"
  default     = "https://aws-api.newrelic.com/cloudwatch-metrics/v1"
}