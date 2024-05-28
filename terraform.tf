
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.3"
    }
    /*
    ansible = {
      source = "ansible/ansible"
      version = "1.2.0"
    }
    */
  }

  required_version = "~> 1.3"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}