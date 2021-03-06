resource "aws_ecr_repository" "notejam" {
  name = "notejam"
  tags = {
    Name = "${var.APP}-${var.ENV}-ecr"
    App  = var.APP
  }
}

resource "aws_ecr_lifecycle_policy" "notejam" {
  repository = aws_ecr_repository.notejam.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

resource "null_resource" "push" {
  provisioner "local-exec" {
    command = "./push.sh ${var.NOTEJAM_SOURCE_PATH} ${aws_ecr_repository.notejam.repository_url} ${var.TAG}"
  }
}
