resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline-${var.app_name}-${var.env}-role"
  assume_role_policy = file("${path.module}/templates/policies/codepipeline_role.json")
}

data "template_file" "codepipeline_policy" {
  template = file("${path.module}/templates/policies/codepipeline.json")

  vars = {
    aws_s3_bucket_arn = aws_s3_bucket.app_source.arn
  }
}

resource "aws_iam_role_policy" "C_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.template_file.codepipeline_policy.rendered
}