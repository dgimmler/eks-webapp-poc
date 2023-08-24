resource "aws_codepipeline" "main" {
  provider = aws

  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Github"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.main.arn
        FullRepositoryId = "dgimmler/eks-webapp-poc"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Test"

    action {
      name             = "Unittest"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["unittest_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.unittest.name
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
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "SAST"

    action {
      name             = "ECRScan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["ecr_scan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.ecr_scan.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["deploy_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }
  }
}

# Supporting resources
# ----------------------------------------------------------

# IMPORTANT
# The authentication must be completed in the AWS console (manual)
resource "aws_codestarconnections_connection" "main" {
  name          = "github-connection"
  provider_type = "GitHub"
}
