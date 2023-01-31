include {
  path = find_in_parent_folders()
}

locals {
  env = "dev"
}

terraform {
  source = "${get_parent_terragrunt_dir()}//terraform"
}

dependency "vapi" {
  config_path = "${get_parent_terragrunt_dir()}/vapi"
}

inputs = {
  env = local.env
  stack_name = "strapi-tuto"
  ecs_cluster_name = dependency.vapi.outputs.ecs_cluster_name
  vpc_id = dependency.vapi.outputs.vpc_id
  lb_listener_arn = dependency.vapi.outputs.lb_listener_arn
  lb_security_group_id = dependency.vapi.outputs.lb_security_group_id
  vpc_private_subnets = dependency.vapi.outputs.vpc_private_subnets
  ecs_task_role_arn = dependency.vapi.outputs.ecs_task_role_arn
  preview_secret_arn = dependency.vapi.outputs.preview_secret_arn[local.env]
  api_url = dependency.vapi.outputs.api_url[local.env]
  lb_dns_name = dependency.vapi.outputs.lb_dns_name
  create_ecr = false
}
