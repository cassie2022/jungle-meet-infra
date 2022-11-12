terraform {
  backend "s3" {
    bucket         = "cassie-terraform-backend"
    key            = "ecs-platform"
    region         = "ap-southeast-2"
    encrypt        = true
  }
}