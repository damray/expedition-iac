provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "palo-${basename(path.cwd)}"
  expedition_name = "exp-${random_string.suffix.result}"

  region = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0,1)

  tags = {
    VPC    = local.name
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 1, k)]

  enable_dns_hostnames = true
  tags = local.tags
}

################################################################################
# Instance Prerequisite
################################################################################

resource "aws_network_interface" "expedition_eni" {
  subnet_id   = module.vpc.public_subnets.0
  private_ips = ["10.0.2.10"]
  security_groups = [aws_security_group.ubuntu_SG.id]

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-2024${var.ubuntu_version}*"]
  }
  filter {
    name = "architecture"
    values = ["${var.architecture}"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "ubuntu-key-${random_string.suffix.result}"
  public_key = file(var.public_key_file)
  }

################################################################################
# Instance Deployment
################################################################################

resource "aws_instance" "expedition" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ubuntu_instance_type
  key_name      = aws_key_pair.deployer.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.expedition_eni.id
  }
  tags = {
    Name = "${local.name}"
  }
}
resource "aws_eip" "ubuntu_eip" {
  domain = "vpc"
  instance                  = aws_instance.expedition.id
  associate_with_private_ip = "10.0.2.10"
  tags = {
    Name = "${local.name}"
  }
}

################################################################################
# Instance Security Group
################################################################################

resource "aws_security_group" "ubuntu_SG" {
  name_prefix = "${local.name}-SG"
  description = "Allow Ubuntu inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "all port allowed"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name = "${local.name}"
  }
}