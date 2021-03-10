data "template_file" "app_buildspec" {
  template = file("${path.module}/templates/buildspec.yml")

  vars = {
    app_name    = var.app_name
    dist_dir    = var.dist_dir
    env         = var.env
    bucket_name = aws_s3_bucket.app_build.bucket
  }
}

resource "aws_codebuild_project" "app_codebuild" {

  name          = "${var.app_name}-${var.env}-codebuild"
  build_timeout = "80"
  service_role  = aws_iam_role.codebuild_role.arn

  depends_on = [aws_s3_bucket.app_build, aws_s3_bucket.app_source]

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
    buildspec = data.template_file.app_buildspec.rendered
  }
}
