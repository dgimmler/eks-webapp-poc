resource "aws_kms_key" "main" {
  provider = aws

  description = var.description
  policy = templatefile("${path.module}/policy.tpl", {
    key_admins   = local.key_admins
    key_services = local.key_services
  })

  tags = var.tags
}

resource "aws_kms_alias" "main" {
  provider = aws

  count = var.key_alias != null ? 1 : 0

  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.main.key_id
}
