Purpose - Terraform template to create SNS and lambda as subscription. Lambda will print the SNS topic message 
Developer - K.Janarthanan

Resources Created
--------------------
1/ Resource Policy for SNS which allow current user to publish/subscribe to it
2/ IAM Role for lambda for accessig Cloudwatch
3/ Resource Based policy for lambda to allow it to be invoked by SNS
4/ Lambda
5/ SNS - Topic
6/ SNS - Subscription

AWS CLI commands
---------------------------
1/ aws sns list-topics
2/ aws sns publish --topic-arn "arn" --message "ABC"