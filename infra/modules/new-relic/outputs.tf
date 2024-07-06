output "integration_role_arn" {
  value       = aws_iam_role.newrelic_integration.arn
  description = "ARN of the IAM role for New Relic integration"
}