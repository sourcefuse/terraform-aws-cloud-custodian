terraform {
  required_version = "~> 1.0.5"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_policy" "ec2" {
  name        = "cloud-custodian-allow-ec2-management"
  description = "Cloud Custodian EC2 policy."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_lambda_basic_execution_role" {
  role       = module.cloud_custodian.role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = module.cloud_custodian.role_name
  policy_arn = aws_iam_policy.ec2.arn
}

module "cloud_custodian" {
  source = "../."

  name      = "tf-cloud-custodian"
  namespace = "refarch"
  region    = "us-east-1"
  stage     = "example"

  custodian_files_path     = "${path.root}/files"
  custodian_templates_path = "${path.root}/templates"

  template_file_vars = {
    EC2_TAG_ROLE = module.cloud_custodian.role_name
  }

  tags = {
    Module  = "terraform-aws-cloud-custodian"
    Example = "true"
  }
}
