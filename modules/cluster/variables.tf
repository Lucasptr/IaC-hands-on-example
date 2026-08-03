variable "subnet_ids" {
  description = "The IDs of the subnets where the instance will be launched."
  type        = list(string)
}

variable "security_group_ids" {
  description = "The ID of the security group to associate with the instance."
  type        = list(string)
}

variable "prefix" {
  description = "The prefix for the resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the instance will be launched."
  type        = string
}

variable "user_data" {
  description = "The user data to provide when launching the instance."
  type        = string
}

variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling group."
  type        = number
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling group."
  type        = number
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling group."
  type        = number
}

variable "scale_out" {
  description = "The scale-out policy for the Auto Scaling group."
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}

variable "scale_in" {
  description = "The scale-in policy for the Auto Scaling group."
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}