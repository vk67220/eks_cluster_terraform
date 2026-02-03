terraform {
  backend "s3" {
    bucket         = "my-eks-terraform-state"
    key            = "eks/${var.cluster_name}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
