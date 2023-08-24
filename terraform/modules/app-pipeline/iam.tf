resource "aws_iam_role" "codepipeline_role" {
  provider = aws

  name               = "${var.pipeline_name}-role"
  description        = "Execution role asumed by ${var.pipeline_name} pipeline"
  assume_role_policy = templatefile("${path.module}/trustPolicy.json", {})

  tags = var.tags
}

resource "aws_iam_policy" "codepipeline_policy" {
  provider = aws

  name        = "${var.pipeline_name}-policy"
  path        = "/"
  description = "Policy for ${var.pipeline_name} pipeline execution role"
  policy      = templatefile("${path.module}/policy.json", {})

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_policy_aattachment" {
  provider = aws

  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}
