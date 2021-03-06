# Auth service deployment
module "auth_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.8"

  name          = "${var.prefix_name}kubernetes-dashboard-ldap-auth"
  namespace     = var.namespace
  image         = var.auth_docker_image
  internal_port = var.service_ports

  env        = local.auth_env
  env_secret = local.auth_env_secret
}
module "auth_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name      = module.auth_deploy.name
  app_namespace = var.namespace
  port_mapping  = var.service_ports
}

# Deployment for recreate new tokens for users service account
module "recreate_token_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.8"

  name      = "${var.prefix_name}kubernetes-dashboard-recreate-tokens"
  namespace = var.namespace
  image     = var.recreate_token_docker_image

  service_account_name  = var.create_admin_role ? kubernetes_service_account.admin_service_account[0].metadata[0].name : var.cluster_admin_role
  service_account_token = true

  env = local.tokens_env
}
