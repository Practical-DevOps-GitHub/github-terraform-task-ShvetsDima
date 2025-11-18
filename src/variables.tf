variable "repository_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
  default     = "Practical-DevOps-GitHub"
}

variable "repository_name" {
  description = "Name of the GitHub repository to configure."
  type        = string
  default     = "github-terraform-task-ShvetsDima"
}

variable "source_branch" {
  description = "Source branch that already exists in GitHub."
  type        = string
  default     = "main"
}

variable "develop_branch" {
  description = "Name of the branch that should become the default branch."
  type        = string
  default     = "develop"
}

variable "collaborator_permission" {
  description = "Permission level for the collaborator."
  type        = string
  default     = "push"
}

variable "deploy_key_public_key" {
  description = "Public deploy key that GitHub will install on the repository."
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOCKPUBLICKEYFORDEPLOYMENT1234567890 example@local"
}

variable "deploy_key_read_only" {
  description = "Control whether the deploy key can only read the repository."
  type        = bool
  default     = true
}

variable "actions_pat" {
  description = "Personal Access Token used as the PAT GitHub Actions secret."
  type        = string
  sensitive   = true
  default     = "ghp_placeholderpersonalaccesstoken0000000000"
}

variable "discord_webhook_url" {
  description = "Webhook URL of the Discord channel that should receive pull request notifications."
  type        = string
  default     = "https://discord.com/api/webhooks/REPLACE_WITH_REAL_WEBHOOK"
}
