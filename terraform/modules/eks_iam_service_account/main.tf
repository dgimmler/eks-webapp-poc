resource "aws_iam_policy" "eks_lb_controller_policy" {
  provider = aws

  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "Required policy needed to set up load balancer controller on EKS"
  policy      = templatefile("${path.module}/policy.json", {})

  tags = var.tags
}

resource "aws_iam_role" "eks_lb_controller_role" {
  provider = aws

  name               = "${var.project_name}-iamservice-role"
  description        = "Required role needed to set up load balancer controller on EKS"
  assume_role_policy = templatefile("${path.module}/trustPolicy.json", {})

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_lb_controller_policy_attachment" {
  provider = aws

  role       = aws_iam_role.eks_lb_controller_role.name
  policy_arn = aws_iam_policy.eks_lb_controller_policy.arn
}
