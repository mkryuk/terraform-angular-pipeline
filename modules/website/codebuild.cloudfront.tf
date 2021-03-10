data "template_file" "cloudfront_buildspec" {
  vars = {
    distribution_id = aws_cloudfront_distribution.app_distribution.id
  }
  template = file("${path.module}/templates/cloudfront.yml")
}

resource "aws_codebuild_project" "cloudfront_invalidation" {

  name          = "${var.app_name}-${var.env}-cloudfront_invalidation"
  build_timeout = "80"
  service_role  = aws_iam_role.codebuild_role.arn

  depends_on = [aws_cloudfront_distribution.app_distribution]

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"

    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.cloudfront_buildspec.rendered
  }
}