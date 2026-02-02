#variable "aws_region" {
  #default = "us-east-1"
#}

#variable "cluster_name" {
  #default = "eks-practice"
#}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

