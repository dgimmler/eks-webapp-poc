resource "aws_ecr_repository" "main" {
  provider = aws

  name                 = var.repo_name
  image_tag_mutability = "MUTABLE" // IMMUTABLE unfortunately does not allow for overwriting :latest

  image_scanning_configuration {
    scan_on_push = true // best practice
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = var.tags
}

resource "aws_ecr_repository_policy" "foopolicy" {
  provider = aws

  repository = aws_ecr_repository.main.name
  policy = templatefile("${path.module}/policy.json", {
    account_id = var.account_id
  })
}