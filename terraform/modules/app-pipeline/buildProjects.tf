resource "aws_codebuild_project" "unittest" {
  name           = local.unittest_project_name
  description    = "Unit test build project for the ${var.pipeline_name} pipeline"
  build_timeout  = "5"
  service_role   = aws_iam_role.codepipeline_role.arn
  encryption_key = var.kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = var.runner_instance_type
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.account_id
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.pipeline_name
      stream_name = "unittest"
      status      = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/unittest.yaml"
  }

  tags = var.tags
}

resource "aws_codebuild_project" "build" {
  name           = local.build_project_name
  description    = "Build application image and push to ECR"
  build_timeout  = "5"
  service_role   = aws_iam_role.codepipeline_role.arn
  encryption_key = var.kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = var.runner_instance_type
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true # required to allow running docker cmds in build script

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.account_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ECR_REPO_URI"
      value = var.ecr_repo_uri
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.pipeline_name
      stream_name = "build"
      status      = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/build.yaml"
  }

  tags = var.tags
}

resource "aws_codebuild_project" "ecr_scan" {
  name           = local.ecr_scan_project_name
  description    = "Check ECR scan results and fail on high or critical vulnerabilities"
  build_timeout  = "5"
  service_role   = aws_iam_role.codepipeline_role.arn
  encryption_key = var.kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = var.runner_instance_type
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.account_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ECR_REPO_NAME"
      value = var.ecr_repo_name
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.pipeline_name
      stream_name = "ecr_scan"
      status      = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/ecr_scan.yaml"
  }

  tags = var.tags
}

resource "aws_codebuild_project" "deploy" {
  name           = local.deploy_project_name
  description    = "Deploy updated application"
  build_timeout  = "5"
  service_role   = aws_iam_role.codepipeline_role.arn
  encryption_key = var.kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = var.runner_instance_type
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true # required to run docker commands

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.account_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ECR_REPO_URI"
      value = var.ecr_repo_uri
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.eks_cluster_name
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.pipeline_name
      stream_name = "deploy"
      status      = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/deploy.yaml"
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "main" {
  name       = var.pipeline_name
  kms_key_id = var.kms_key_arn

  tags = var.tags
}
