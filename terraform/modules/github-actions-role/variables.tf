variable "role_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repo format"
  type        = string
}

variable "allowed_branch" {
  type    = string
  default = "main"
}

variable "policy_arns" {
  description = "IAM policies to attach to the GitHub Actions role."
  type        = map(string)
}
