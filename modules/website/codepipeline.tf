resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.app_name}-${var.env}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  depends_on = [aws_s3_bucket.app_build, aws_s3_bucket.app_source]

  artifact_store {
    location = aws_s3_bucket.app_source.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        Owner      = var.git_repository_owner
        Repo       = var.git_repository_name
        Branch     = var.git_repository_branch
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      version          = "1"

      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
          ]
        )
        ProjectName = aws_codebuild_project.app_codebuild.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.manual_approve ? [1] : []
    content {
      name = "Approve"
      action {
        name     = "Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "BucketName" = aws_s3_bucket.app_build.bucket
        "Extract"    = "true"
      }
      input_artifacts = [
        "build",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "CloudfrontInvalidation"
    action {
      name     = "CloudfrontInvalidation"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"
      input_artifacts = [
        "build",
      ]

      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
          ]
        )
        ProjectName = aws_codebuild_project.cloudfront_invalidation.name
      }
    }
  }
}
