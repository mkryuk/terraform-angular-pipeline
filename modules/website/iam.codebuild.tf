resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-${var.app_name}-${var.env}-role"
  assume_role_policy = file("${path.module}/templates/policies/codebuild_role.json")
}

data "template_file" "codebuild_policy" {
  template = file("${path.module}/templates/policies/codebuild.json")

  vars = {
    aws_s3_bucket_arn = aws_s3_bucket.app_source.arn
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild-${var.app_name}-${var.env}-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.template_file.codebuild_policy.rendered
}
