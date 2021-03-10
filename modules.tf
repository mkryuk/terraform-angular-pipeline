module "app" {
  source                = "./modules/website"
  app_name              = var.app_name
  dist_dir              = var.dist_dir
  env                   = var.env
  app_domain            = var.app_domain
  aws_region            = var.aws_region
  github_token          = var.github_token
  git_repository_owner  = var.git_repository_owner
  git_repository_name   = var.git_repository_name
  git_repository_branch = var.git_repository_branch
  account_id            = data.aws_caller_identity.current.account_id
  manual_approve        = var.manual_approve
}
