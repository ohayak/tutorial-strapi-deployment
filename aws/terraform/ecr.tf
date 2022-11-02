resource "aws_ecr_repository" "image_repo" {
  name = var.stack_name

  image_scanning_configuration {
    scan_on_push = false
  }
}
resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.image_repo.name

  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["latest"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )
}
