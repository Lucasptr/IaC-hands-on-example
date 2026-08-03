terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
    }
  }
}

data "aws_lb" "terraform_lb_test" {
  arn = var.lb_arn
}

data "http" "terraform_lb_test" {
  url = "http://${data.aws_lb.terraform_lb_test.dns_name}"
  request_timeout_ms = 5000
  retry {
    attempts = 5
    min_delay_ms = 1000
    max_delay_ms = 10000
  }
}