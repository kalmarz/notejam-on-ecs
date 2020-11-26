variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "APP" {
  default = "notejam"
}

variable "ENV" {
  default = "dev"
}

variable "TASK_CPU" {
  default = "256"
}

variable "TASK_MEMORY" {
  default = "512"
}

variable "CONTAINER_PORT" {
  default = "3000"
}

variable "CONTAINER_PATH" {
  default = "/notejam/db"
}

variable "NOTEJAM_SOURCE_PATH" {
  default = "../notejam"
}

variable "TAG" {
  default = "latest"
}

variable "SUBNET_NUMBER" {
  default = 3
}
