resource "aws_ecr_repository" "image_repository" {
  name = var.stack_name

  image_scanning_configuration {
    scan_on_push = false
  }
  
  force_delete = true
}
resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.image_repository.name

  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["backend"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }

        },
        {
          "rulePriority" : 2,
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["frontend"],
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
