provider "aws" {
  region = "us-west-2"
}

variables {
  prefix             = "test"
  vpc_cidr_block     = "10.0.0.0/18"
  subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
}

run "validate_vpc" {
  command = plan

  assert {
    condition     = aws_vpc.terraform_vpc.cidr_block == "10.0.0.0/18"
    error_message = "VPC CIDR block does not match expected value"
  }

  assert {
    condition     = aws_vpc.terraform_vpc.tags["Name"] == "test-terraform-vpc"
    error_message = "VPC Name tag does not match expected value"
  }
}


run "validate_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.terraform_subnets) == length(var.subnet_cidr_blocks)
    error_message = "Number of subnets does not match expected value"
  }

  assert {
    condition     = aws_subnet.terraform_subnets[0].cidr_block == "10.0.0.0/24"
    error_message = "First subnet CIDR block does not match expected value"
  }

  assert {
    condition     = aws_subnet.terraform_subnets[1].cidr_block == "10.0.1.0/24"
    error_message = "Second subnet CIDR block does not match expected value"
  }

  assert {
    condition     = aws_subnet.terraform_subnets[0].availability_zone != aws_subnet.terraform_subnets[1].availability_zone
    error_message = "Subnets are not in different availability zones"
  }
}
