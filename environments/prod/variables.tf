variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "The CIDR blocks for the subnets"
  type        = list(string)
}

variable "prefix" {
  description = "The prefix for the resources"
  type        = string
}

variable "scale_in" {
  description = "The scale-in policy for the Auto Scaling group."
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}

variable "scale_out" {
  description = "The scale-out policy for the Auto Scaling group."
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}