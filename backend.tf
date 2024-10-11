# Terraform cloud is used as the backend for storing the terraform state files
terraform {
  cloud {
    organization = "xxxxxxx"

    workspaces {
      name = "xxxxx"
    }
  }
}
