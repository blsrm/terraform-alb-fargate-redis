resource "aws_cloudwatch_log_group" "streamapp" {
  name              = "/ecs/streamapp"
  retention_in_days = 30
  tags = {
    Name = "streamapp"
  }
}

/**
 * This component creates a CloudWatch dashboard for you app,
 * showing its CPU and memory utilization and various HTTP-related metrics.
 *
 * The graphs of HTTP requests are stacked.  Green indicates successful hits
 * (HTTP response codes 2xx), yellow is used for client errors (HTTP response
 * codes 4xx) and red is used for server errors (HTTP response codes 5xx).
 * Stacking is used because, when things are running smoothly, those graphs
 * will be predominately green, making the dashboard easier to check
 * at a glance or at a distance.
 *
 * One of the graphs shows HTTP response codes returned by your containers.
 * Another graph shows HTTP response codes returned by your load balancer.
 * Although these two graphs often look very similar, there are situations
 * where they will differ.
 * If your containers are responding 200 OK but are taking too long to
 * respond, the load balancer will return 504 Gateway Timeout.  In that
 * case, the containers' graph could show green while the load balancer's
 * graph shows red.
 * If many of your containers are failing their healthchecks, the load
 * balancer will direct traffic to the healthy containers.  In that case,
 * the load balancer's graph could show green while the containers'
 * graph shows red.
 * The containers' graph might show more traffic than the load balancer's.
 * Some of the containers' traffic is due to the healthchecks, which
 * originate with the load balancer.  Also, it is possible that future
 * load balancers will re-attempt HTTP requests that the HTTP standard
 * declares idempotent.
 *
 */

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "streamapp-${var.environment}-fargate"

  dashboard_body = <<EOF
  {
     "widgets":[
        {
           "type":"metric",
           "x":12,
           "y":6,
           "width":12,
           "height":6,
           "properties":{
              "view":"timeSeries",
              "stacked":false,
              "metrics":[
                 [
                    "AWS/ECS",
                    "MemoryUtilization",
                    "ServiceName",
                    "streamapp-${var.environment}",
                    "ClusterName",
                    "streamapp-${var.environment}",
                    {
                       "color":"#1f77b4"
                    }
                 ],
                 [
                    ".",
                    "CPUUtilization",
                    ".",
                    ".",
                    ".",
                    ".",
                    {
                       "color":"#9467bd"
                    }
                 ]
              ],
              "region":"${var.aws_region}",
              "period":300,
              "title":"Memory and CPU utilization",
              "yAxis":{
                 "left":{
                    "min":0,
                    "max":100
                 }
              }
           }
        },
        {
           "type":"metric",
           "x":0,
           "y":6,
           "width":12,
           "height":6,
           "properties":{
              "view":"timeSeries",
              "stacked":true,
              "metrics":[
                 [
                    "AWS/ApplicationELB",
                    "HTTPCode_Target_5XX_Count",
                    "TargetGroup",
                    "${aws_alb_target_group.app.arn_suffix}",
                    "LoadBalancer",
                    "${aws_alb.main.arn_suffix}",
                    {
                       "period":60,
                       "color":"#d62728",
                       "stat":"Sum"
                    }
                 ],
                 [
                    ".",
                    "HTTPCode_Target_4XX_Count",
                    ".",
                    ".",
                    ".",
                    ".",
                    {
                       "period":60,
                       "stat":"Sum",
                       "color":"#bcbd22"
                    }
                 ],
                 [
                    ".",
                    "HTTPCode_Target_3XX_Count",
                    ".",
                    ".",
                    ".",
                    ".",
                    {
                       "period":60,
                       "stat":"Sum",
                       "color":"#98df8a"
                    }
                 ],
                 [
                    ".",
                    "HTTPCode_Target_2XX_Count",
                    ".",
                    ".",
                    ".",
                    ".",
                    {
                       "period":60,
                       "stat":"Sum",
                       "color":"#2ca02c"
                    }
                 ]
              ],
              "region":"${var.aws_region}",
              "title":"Container responses",
              "period":300,
              "yAxis":{
                 "left":{
                    "min":0
                 }
              }
           }
        },
        {
           "type":"metric",
           "x":12,
           "y":0,
           "width":12,
           "height":6,
           "properties":{
              "view":"timeSeries",
              "stacked":false,
              "metrics":[
                 [
                    "AWS/ApplicationELB",
                    "TargetResponseTime",
                    "LoadBalancer",
                    "${aws_alb.main.arn_suffix}",
                    {
                       "period":60,
                       "stat":"p50"
                    }
                 ],
                 [
                    "...",
                    {
                       "period":60,
                       "stat":"p90",
                       "color":"#c5b0d5"
                    }
                 ],
                 [
                    "...",
                    {
                       "period":60,
                       "stat":"p99",
                       "color":"#dbdb8d"
                    }
                 ]
              ],
              "region":"${var.aws_region}",
              "period":300,
              "yAxis":{
                 "left":{
                    "min":0,
                    "max":3
                 }
              },
              "title":"Container response times"
           }
        },
        {
           "type":"metric",
           "x":12,
           "y":12,
           "width":12,
           "height":2,
           "properties":{
              "view":"singleValue",
              "metrics":[
                 [
                    "AWS/ApplicationELB",
                    "HealthyHostCount",
                    "TargetGroup",
                    "${aws_alb_target_group.app.arn_suffix}",
                    "LoadBalancer",
                    "${aws_alb.main.arn_suffix}",
                    {
                       "color":"#2ca02c",
                       "period":60
                    }
                 ],
                 [
                    ".",
                    "UnHealthyHostCount",
                    ".",
                    ".",
                    ".",
                    ".",
                    {
                       "color":"#d62728",
                       "period":60
                    }
                 ]
              ],
              "region":"${var.aws_region}",
              "period":300,
              "stacked":false
           }
        },
        {
           "type":"metric",
           "x":0,
           "y":0,
           "width":12,
           "height":6,
           "properties":{
              "view":"timeSeries",
              "stacked":true,
              "metrics":[
                 [
                    "AWS/ApplicationELB",
                    "HTTPCode_Target_5XX_Count",
                    "LoadBalancer",
                    "${aws_alb.main.arn_suffix}",
                    {
                       "period":60,
                       "stat":"Sum",
                       "color":"#d62728"
                    }
                 ],
                 [
                    ".",
                    "HTTPCode_Target_4XX_Count",
                    ".",
                    ".",
                    {
                       "period":60,
                       "stat":"Sum",
                       "color":"#bcbd22"
                    }
                 ],
                 [
                    ".",
                    "HTTPCode_Target_3XX_Count",
                    ".",
                    ".",
                    {
                       "period":60,
                       "stat":"Sum",
                       "color":"#98df8a"
                    }
                 ],
                 [
                    ".",
                    "HTTPCode_Target_2XX_Count",
                    ".",
                    ".",
                    {
                       "period":60,
                       "stat":"Sum",
                       "color":"#2ca02c"
                    }
                 ]
              ],
              "region":"${var.aws_region}",
              "title":"Load balancer responses",
              "period":300,
              "yAxis":{
                 "left":{
                    "min":0
                 }
              }
           }
        }
     ]
  }
EOF
}

/**
 * ECS Event Stream
 * This component gives you full access to the ECS event logs
 * for your cluster by creating a cloudwatch event rule that listens for
 * events for this cluster and calls a lambda that writes them to cloudwatch logs.
 * It then adds a cloudwatch dashboard the displays the results of a
 * logs insights query against the lambda logs
 */

# cw event rule
resource "aws_cloudwatch_event_rule" "ecs_event_stream" {
  name        = "streamapp-${var.environment}-ecs-event-stream"
  description = "Passes ecs event logs for streamapp-${var.environment} to a lambda that writes them to cw logs"

  event_pattern = <<PATTERN
  {
    "detail": {
      "clusterArn": ["${aws_ecs_cluster.main.arn}"]
    }
  }

PATTERN

}

resource "aws_cloudwatch_event_target" "ecs_event_stream" {
  rule = aws_cloudwatch_event_rule.ecs_event_stream.name
  arn  = aws_lambda_function.ecs_event_stream.arn
}

data "template_file" "lambda_source" {
  template = <<EOF
exports.handler = (event, context, callback) => {
  console.log(JSON.stringify(event));
}
EOF

}

data "archive_file" "lambda_zip" {
  type                    = "zip"
  source_content          = data.template_file.lambda_source.rendered
  source_content_filename = "index.js"
  output_path             = "lambda-streamapp.zip"
}

resource "aws_lambda_permission" "ecs_event_stream" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_event_stream.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_event_stream.arn
}

resource "aws_lambda_function" "ecs_event_stream" {
  function_name    = "streamapp-${var.environment}-ecs-event-stream"
  role             = aws_iam_role.ecs_event_stream.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  tags = {
    Name = "Lambda Cloudwatch"
    Owner = "${var.tag_owner}"
    Usage = "${var.tag_usage}"
  }
}

resource "aws_lambda_alias" "ecs_event_stream" {
  name             = aws_lambda_function.ecs_event_stream.function_name
  description      = "latest"
  function_name    = aws_lambda_function.ecs_event_stream.function_name
  function_version = "$LATEST"
}

resource "aws_iam_role" "ecs_event_stream" {
  name = aws_cloudwatch_event_rule.ecs_event_stream.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ecs_event_stream" {
  role       = aws_iam_role.ecs_event_stream.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# cloudwatch dashboard with logs insights query
resource "aws_cloudwatch_dashboard" "ecs-event-stream" {
  dashboard_name = "streamapp-${var.environment}-ecs-event-stream"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 24,
      "height": 18,
      "properties": {
        "query": "SOURCE '/aws/lambda/streamapp-${var.environment}-ecs-event-stream' | fields @timestamp as time, detail.desiredStatus as desired, detail.lastStatus as latest, detail.stoppedReason as reason, detail.containers.0.reason as container_reason, detail.taskDefinitionArn as task_definition\n| filter @type != \"START\" and @type != \"END\" and @type != \"REPORT\"\n| sort detail.updatedAt desc, detail.version desc\n| limit 100",
        "region": "${var.aws_region}",
        "title": "ECS Event Log"
      }
    }
  ]
}
EOF
}
