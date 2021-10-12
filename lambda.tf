//lambda source
resource "aws_lambda_function" "sns_lambda" {
  filename      = var.lambda_file
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "read_sns.read_message"
  publish       = true
  description  = "To read message from SNS Topic ${var.sns_topic_name}"

  source_code_hash = filebase64sha256(var.lambda_file)

  runtime = "python3.9"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
}

//Role for Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.lambda_function_name}_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_function_name}_lambda_policy"
  path        = "/"
  description = "${var.lambda_function_name} lambda policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

//Resource policy for Lambda to allow invocation from SNS
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "${var.sns_topic_name}_allow_invocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns-topic.arn
}