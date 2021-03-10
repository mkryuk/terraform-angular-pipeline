variable "aws_region" {
  type        = string
  description = "AWS Region for the VPC"
  default     = "us-west-2"
}

variable "app_name" {
  type        = string
  description = "Website project name"
  default     = "app_name"
}

variable "dist_dir" {
  type        = string
  description = "Website distribution directory"
  default     = "dist"
}

variable "env" {
  type        = string
  description = "Depolyment environment"
  default     = "dev"
}

variable "app_domain" {
  description = "Main app domain, e.g. somedomain.xyz"
  type        = string
}

variable "git_repository_owner" {
  type        = string
  description = "Github repository owner name"
  default     = ""
}

variable "github_token" {
  type        = string
  description = "Github token"
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

variable "manual_approve" {
  type        = bool
  description = "Toggle to enable or disable manual approve step in pipeline"
  default     = false
}
