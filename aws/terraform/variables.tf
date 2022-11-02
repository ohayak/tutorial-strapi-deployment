variable "stack_name" {
  description = "(Required) The name of the product you are deploying."
  type        = string
  default     = "strapi-tutorial"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "container_name" {
  type    = string
  default = "vapi"
}

variable "container_port" {
  type    = number
  default = 1337
}

variable "public_port" {
  type    = number
  default = 80
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}