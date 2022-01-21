provider "aws" {
  region = "ap-southeast-2"
}

# data "archive_file" "bootstrap-zip" {
#   type        = "zip"
#   source_file  = "./target/release/bootstrap"
#   output_path = "bootstrap.zip"
# }

resource "aws_iam_role" "lambda_iam_2" {
  name = "lambda_iam_2"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow"
          "Sid" : ""
        }
      ]
    }
  )
}


resource "aws_lambda_function" "lambda" {
  filename         = "bootstrap.zip"
  function_name    = "aws-lamda-rust-cookie-fn"
  role             = aws_iam_role.lambda_iam_2.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = filebase64sha256("bootstrap.zip")
  runtime          = "provided.al2"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.example,
  ]
}

resource "aws_apigatewayv2_api" "lambda-api-cookie" {
  name          = "v2-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda-api-stage" {
  api_id      = aws_apigatewayv2_api.lambda-api-cookie.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda-api-integration" {
  api_id               = aws_apigatewayv2_api.lambda-api-cookie.id
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lambda-route" {
  api_id    = aws_apigatewayv2_api.lambda-api-cookie.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda-api-integration.id}"
}

resource "aws_lambda_permission" "api-lambda-gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda-api-cookie.execution_arn}/*/*/*"
}


# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/aws_lamda_rust_cookie_fn"
  retention_in_days = 14
}


# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_iam_2.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


