output "function_name" {
  description = "Nom à utiliser pour vérifier et invoquer la Lambda."
  value       = aws_lambda_function.hello.function_name
}

output "function_arn" {
  description = "Identifiant AWS de la Lambda déployée."
  value       = aws_lambda_function.hello.arn
}
