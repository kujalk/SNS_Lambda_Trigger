//SNS topic
resource "aws_sns_topic" "sns-topic" {
  name         = var.sns_topic_name
  display_name = var.sns_topic_name
  fifo_topic   = false //only standary fifo support lambda invocation
}

//SNS subscription
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.sns-topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_lambda.arn
}

//SNS policy attachment
resource "aws_sns_topic_policy" "policy" {
  arn    = aws_sns_topic.sns-topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_caller_identity" "current" {}

//SNS policy
data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "${var.sns_topic_name}_policy"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.sns-topic.arn,
    ]

    sid = "${var.sns_topic_name}_sid"
  }
}