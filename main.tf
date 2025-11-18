terraform {
  required_version = ">= 1.5.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.2"
    }
  }
}

provider "github" {
  owner = var.repository_owner
}

data "github_repository" "current" {
  full_name = "${var.repository_owner}/${var.repository_name}"
}

locals {
  collaborator = "softservedata"

  codeowners_content = <<-EOT
    * @softservedata
  EOT

  pull_request_template = <<-EOT
    ## Describe your changes

    ## Issue ticket number and link

    ## Checklist before requesting a review
    - [ ] I have performed a self-review of my code
    - [ ] If it is a core feature, I have added thorough tests
    - [ ] Do we need to implement analytics?
    - [ ] Will this be part of a product update? If yes, please write one phrase about this update
  EOT
}

resource "github_branch" "develop" {
  repository    = var.repository_name
  branch        = var.develop_branch
  source_branch = var.source_branch
}

resource "github_branch_default" "default" {
  repository = var.repository_name
  branch     = github_branch.develop.branch
}

resource "github_repository_collaborator" "softservedata" {
  repository = var.repository_name
  username   = local.collaborator
  permission = var.collaborator_permission
}

resource "github_branch_protection" "develop" {
  repository_id = data.github_repository.current.node_id
  pattern       = github_branch.develop.branch

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 2
  }
}

resource "github_branch_protection" "main" {
  repository_id = data.github_repository.current.node_id
  pattern       = var.source_branch

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 0
  }
}

resource "github_repository_file" "codeowners" {
  repository          = var.repository_name
  branch              = var.source_branch
  file                = ".github/CODEOWNERS"
  content             = trimspace(local.codeowners_content)
  commit_message      = "chore: add CODEOWNERS for main branch"
  overwrite_on_create = true

  depends_on = [github_branch.develop]
}

resource "github_repository_file" "pull_request_template" {
  repository          = var.repository_name
  branch              = var.source_branch
  file                = ".github/pull_request_template.md"
  content             = trimspace(local.pull_request_template)
  commit_message      = "chore: add pull request template"
  overwrite_on_create = true

  depends_on = [github_branch.develop]
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = var.repository_name
  title      = "DEPLOY_KEY"
  key        = var.deploy_key_public_key
  read_only  = var.deploy_key_read_only
}

resource "github_actions_secret" "pat" {
  repository      = var.repository_name
  secret_name     = "PAT"
  plaintext_value = var.actions_pat
}

resource "github_repository_webhook" "discord_pull_requests" {
  repository = var.repository_name

  configuration {
    url          = var.discord_webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true
  events = ["pull_request"]
}

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

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default     = "ghp_placeholderpersonalaccesstoken0000000000"
}

variable "discord_webhook_url" {
  description = "Webhook URL of the Discord channel that should receive pull request notifications."
  type        = string
  default     = "https://discord.com/api/webhooks/REPLACE_WITH_REAL_WEBHOOK"
}
