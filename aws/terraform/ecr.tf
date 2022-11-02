resource "aws_ecr_repository" "image-repo" {
  name = "strapi-tutu"

  image_scanning_configuration {
    scan_on_push = false
  }
}
resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.image-repo.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["dev"],
            "countType": "imageCountMoreThan",
            "countNumber": 1
        },
        "action": {
            "type": "expire"
        }
    ]
  }
  EOF
}
