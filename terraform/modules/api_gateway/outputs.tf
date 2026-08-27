output "invoke_url" {
  description = "URL de invocação da API"
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}