resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_lambda_function" "hello" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.13"
  handler          = "lambda_function.lambda_handler"
  filename         = "${path.module}/../../lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../../lambda.zip")
  timeout          = 3
  memory_size      = 128
}
