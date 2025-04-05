resource "github_actions_secret" "aws_access_key_id" {
  repository      = var.github_repository
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key_id
}

resource "github_actions_secret" "aws_secret_access_key" {
  repository      = var.github_repository
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_access_key
}

resource "github_actions_secret" "aws_region" {
  repository      = var.github_repository
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "ecs_cluster" {
  repository      = var.github_repository
  secret_name     = "ECS_CLUSTER"
  plaintext_value = aws_ecs_cluster.medusa_cluster.name
}

resource "github_actions_secret" "ecs_service" {
  repository      = var.github_repository
  secret_name     = "ECS_SERVICE"
  plaintext_value = aws_ecs_service.medusa.name
}

resource "github_actions_secret" "ecr_repository" {
  repository      = var.github_repository
  secret_name     = "ECR_REPOSITORY"
  plaintext_value = aws_ecr_repository.medusa.repository_url
}

resource "github_repository_file" "github_workflow" {
  repository          = var.github_repository
  branch              = "main"
  file                = ".github/workflows/deploy.yml"
  content             = templatefile("${path.module}/templates/github-workflow.yml.tpl", {
    ecr_repository = aws_ecr_repository.medusa.repository_url
    aws_region     = var.aws_region
  })
  commit_message      = "Add GitHub Actions workflow"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

resource "aws_ecr_repository" "medusa" {
  name                 = "medusa"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_user" "github_actions" {
  name = "github-actions-medusa"
}

resource "aws_iam_user_policy_attachment" "github_actions_ecr" {
  user       = aws_iam_user.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_user_policy_attachment" "github_actions_ecs" {
  user       = aws_iam_user.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
