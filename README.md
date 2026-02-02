STEP 1: Decide secret placement (IMPORTANT)
✅ Repository Secrets (WHO – credentials)

Same for all environments.

Create these as Repository Secrets:

Secret Name	Used for
AWS_ACCESS_KEY_ID	AWS auth
AWS_SECRET_ACCESS_KEY	AWS auth
✅ Environment Secrets (WHERE – config)

Different per environment.

Environment: dev
Secret	Value
AWS_REGION	us-east-1
CLUSTER_NAME	eks-dev

Environment: production
Secret	Value
AWS_REGION	us-east-1
CLUSTER_NAME	eks-prod

🔐 STEP 2: Create the secrets (UI steps)

In GitHub:

Repository secrets
Repo → Settings
→ Secrets and variables
→ Actions
→ New repository secret


Add:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

Environment secrets
Repo → Settings → Environments
→ New environment


Create:

dev

production

Add secrets inside each environment:

AWS_REGION

CLUSTER_NAME

(Optional but recommended)
✔ Enable Required reviewers for production

🧩 STEP 3: Small Terraform cleanup (RECOMMENDED)

Your variables.tf currently has defaults.
To fully rely on GitHub secrets, remove defaults.

✅ Updated variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}


⚠️ This prevents accidental cluster creation with wrong values.

🚀 STEP 4: GitHub Actions Workflow (MATCHES YOUR TF)

This workflow directly matches your Terraform code.

name: Terraform EKS Cluster

on:
  workflow_dispatch:
    inputs:
      target_env:
        description: "Select environment"
        required: true
        type: choice
        options:
          - dev
          - production

jobs:
  terraform:
    name: Create EKS Cluster
    runs-on: ubuntu-latest

    # 🔐 REQUIRED for environment secrets
    environment: ${{ inputs.target_env }}

    env:
      # ✅ Repository secrets (credentials)
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      # ✅ Environment secrets (config)
      AWS_REGION: ${{ secrets.AWS_REGION }}
      CLUSTER_NAME: ${{ secrets.CLUSTER_NAME }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.6

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: |
          terraform plan \
            -var="aws_region=$AWS_REGION" \
            -var="cluster_name=$CLUSTER_NAME"

      - name: Terraform Apply
        run: |
          terraform apply -auto-approve \
            -var="aws_region=$AWS_REGION" \
            -var="cluster_name=$CLUSTER_NAME"

🔍 STEP 5: What happens at runtime
If you select dev

Injected automatically:

AWS_REGION=us-east-1
CLUSTER_NAME=eks-dev


Terraform creates:

EKS cluster → eks-dev
VPC + subnets
Managed node group

If you select production

Injected:

AWS_REGION=us-east-1
CLUSTER_NAME=eks-prod


If approvals enabled → workflow pauses for approval ✅
