
module "develop" {
  source                    = "./modules/website"
  app_name                  = var.app_name
  env                       = var.env
  domain_names              = var.domain_names
  aws_region                = var.aws_region
  github_token              = var.github_token
  git_repository_owner      = var.git_repository_owner
  git_repository_name       = var.git_repository_name
  git_repository_branch     = var.git_repository_branch
  git_repository_dev_branch = var.git_repository_dev_branch
  account_id                = data.aws_caller_identity.current.account_id
}

module "production" {
  source                    = "./modules/website"
  app_name                  = var.app_name
  env                       = var.env
  domain_names              = var.domain_names
  aws_region                = var.aws_region
  github_token              = var.github_token
  git_repository_owner      = var.git_repository_owner
  git_repository_name       = var.git_repository_name
  git_repository_branch     = var.git_repository_branch
  git_repository_dev_branch = var.git_repository_dev_branch
  account_id                = data.aws_caller_identity.current.account_id
}
