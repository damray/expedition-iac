variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "public_key_file" {
  description = "Full path to the SSH public key file"
    default = "~/.ssh/aws_lab.pub"
  type        = string
}

variable "ubuntu_version" {
  description ="mois du deploiement"
  type        = string
  default     = "0426"
}

variable "ubuntu_instance_type" {
  description = "type d'instance aws"
  type        = string
  default     = "t2.large"
}

variable "architecture" {
    description = "Architecture x86_64"
    type = string
    default = "x86_64"
  
}