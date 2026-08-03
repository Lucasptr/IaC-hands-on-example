provider "aws" {
  region = "us-west-2"
}

variables {
  prefix = "test"
}

// Setup
run "network" {
  command = apply

  variables {
    vpc_cidr_block     = "10.0.0.0/18"
    subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  }

  module {
    source = "../network"
  }

  assert {
    condition     = length(output.subnet_ids) == 2
    error_message = "Expected 2 subnets to be created"
  }
}

run "cluster" {
  command = apply

  variables {
    subnet_ids         = run.network.subnet_ids
    security_group_ids = [run.network.security_group_id]
    vpc_id             = run.network.vpc_id
    user_data          = <<EOF
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
EOF
    desired_capacity   = 1
    min_size           = 1
    max_size           = 1
    instance_count     = 2
    scale_in = {
      cooldown           = 60
      threshold          = 20
      scaling_adjustment = -1
    }
    scale_out = {
      cooldown           = 60
      threshold          = 70
      scaling_adjustment = 1
    }
  }

  // Module configuration for the cluster module, because its kwnow only after the network is created  
  assert {
    condition     = aws_lb.terraform_lb.dns_name != null
    error_message = "Load balancer DNS name should not be null"
  }

  assert {
    condition     = output.lb_arn != null
    error_message = "Load balancer ARN should not be null"
  }
}

run "verify_http" {
  command = apply

  variables {
    lb_arn = run.cluster.lb_arn
  }

  module {
    source = "./testing/http"
  }

  assert {
    condition     = data.http.terraform_lb_test.status_code == 200
    error_message = "Expected HTTP status code 200 from the load balancer"
  }
}
