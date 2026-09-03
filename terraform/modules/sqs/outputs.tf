output "queue_arn" {
  description = "ARN da fila principal de leads"
  value       = aws_sqs_queue.main.arn
}

output "queue_url" {
  description = "URL da fila principal de leads"
  value       = aws_sqs_queue.main.url
}

output "dlq_arn" {
  description = "ARN da DLQ de leads"
  value       = aws_sqs_queue.dlq.arn
}
