variable "app_name" {
  type        = string
  description = "Website project name"
  default     = "app_name"
}

variable "env" {
  description = "Depolyment environment"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS Region for the VPC"
  default     = "us-west-2"
}

variable "domain_names" {
  type        = list(string)
  default     = []
  description = "The list of domain names associated to cloudfront"
}

variable "git_repository_owner" {
  type        = string
  description = "Github Repository Owner"
  default     = ""
}

variable "github_token" {
  type        = string
  description = "Github Repository Owner"
  default     = ""
}

variable "git_repository_name" {
  type        = string
  description = "Project name on Github"
  default     = ""
}

variable "git_repository_branch" {
  type        = string
  description = "Github Project Branch"
  default     = "master"
}

variable "git_repository_dev_branch" {
  type        = string
  description = "Github Project Branch"
  default     = "develop"
}
