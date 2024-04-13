terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com", "codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "test73"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.example.name
}

resource "aws_codedeploy_app" "my_application" {
  name = "test73"
}

resource "aws_codedeploy_deployment_group" "my_group" {
  app_name              = aws_codedeploy_app.my_application.name
  deployment_group_name = "my_group"
  service_role_arn      = aws_iam_role.example.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "kops"
    }
  }
}

# resource "aws_codestarconnections_connection" "example" {
#   name          = "example-connection"
#   provider_type = "GitHub"
# }

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "nnannasamueltesttfbuk7308085866162"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_codepipeline" "codepipeline" {
  pipeline_type = "V2"
  name     = "test73-pipeline"
  role_arn = aws_iam_role.example.arn
  
  
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:197383505749:connection/6e2f1d05-9382-42f0-ad8d-aa2c7f542327"
        FullRepositoryId = "vprofile-project"
        BranchName       = "kubernetes-setup"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = []
      version         = "1"     

      configuration = {
        ApplicationName = "my_application"
        DeploymentGroupName = "my_group"
      }
    }
  }
}