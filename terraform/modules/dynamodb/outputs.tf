output "table_name" {
  value = aws_dynamodb_table.leads.name
}

output "table_arn" {
  value = aws_dynamodb_table.leads.arn
}
