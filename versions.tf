terraform {
  required_version = ">= 0.14"

  required_providers {
    aws        = ">= 4.0"
    helm       = ">= 1.0, < 3.0"
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.4"
    }
  }
}
