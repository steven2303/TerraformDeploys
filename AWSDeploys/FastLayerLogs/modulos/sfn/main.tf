resource "aws_sfn_state_machine" "sfn_log_processing_state_machine" {
  name     = var.sfn_state_machine_name
  role_arn = aws_iam_role.sfn_role.arn # var.sfn_audit_log_iam_role_arn ########################################## ROL AQUI
  definition = <<EOF
    {
  "Comment": "State Machine for uploading new log",
  "StartAt": "Glue StartJobRun",
  "States": {   
    "Glue StartJobRun": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun",
      "Parameters": {
        "JobName": "${var.glue_audit_log_job_name}",  
        "Arguments": {
          "--bucket_name.$": "$.bucket_name",
          "--file_name.$": "$.file_name",
          "--log_destination.$": "$.log_destination",
          "--error_destination.$": "$.error_destination"
        }
      },
      "Next": "CheckGlueJobStatus"
    },
    "CheckGlueJobStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${var.lambda_glue_status_monitor_function_arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Next": "DetermineJobStatus"
    },
    "DetermineJobStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.status",
          "StringEquals": "RUNNING",
          "Next": "WaitForJobCompletion"
        }
      ],
      "Default": "InitialGetCrawler"
    },
    "InitialGetCrawler": {
      "Type": "Task",
      "Next": "DecideCrawlerAction",
      "Parameters": {
        "Name": "${var.glue_audit_log_crawler_name}"
      },
      "Resource": "arn:aws:states:::aws-sdk:glue:getCrawler"
    },
    "DecideCrawlerAction": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Crawler.State",
          "StringEquals": "READY",
          "Next": "StartCrawler"
        },
        {
          "Variable": "$.Crawler.State",
          "StringEquals": "STOPPING",
          "Next": "NotifyJobStatus"
        }
      ],
      "Default": "WaitForCrawlerReadiness"
    },
    "WaitForCrawlerReadiness": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "InitialGetCrawler"
    },
    "WaitForJobCompletion": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckGlueJobStatus"
    },
    "StartCrawler": {
      "Type": "Task",
      "Parameters": {
        "Name": "${var.glue_audit_log_crawler_name}"
      },
      "Resource": "arn:aws:states:::aws-sdk:glue:startCrawler",
      "Next": "GetCrawler"
    },
    "GetCrawler": {
      "Type": "Task",
      "Parameters": {
        "Name": "${var.glue_audit_log_crawler_name}"  
      },
      "Resource": "arn:aws:states:::aws-sdk:glue:getCrawler",
      "Next": "EvaluateCrawlerState"
    },
    "EvaluateCrawlerState": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Crawler.State",
          "StringEquals": "RUNNING",
          "Next": "WaitForCrawlerStateUpdate"
        }
      ],
      "Default": "NotifyJobStatus"
    },
    "WaitForCrawlerStateUpdate": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "GetCrawler"
    },
    "NotifyJobStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${var.sns_etl_job_topic_arn}",
        "Message": "El proceso ETL ha culminado satisfactoriamente"
      },
      "End": true
    }
  }
}
EOF
}