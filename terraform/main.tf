terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.52.0"
    }
  }
  backend "s3" {
    bucket = "bank-network-tfstate"
    region = "us-east-1"
    key = "terraform.tfstate"
    dynamodb_table = "bucket-tfstate"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

locals {
  tags = {
    Terraform = true
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "bank-network"
  cidr = "192.168.0.0/16"

  azs              = ["us-east-1b"]
  public_subnets   = [cidrsubnet("192.168.0.0/16", 8, 1)]
  private_subnets  = ["192.168.20.0/24", "192.168.21.0/24", "192.168.22.0/24", cidrsubnet("192.168.0.0/16", 8, 40)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "public-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "public-subnet-sg"
  description = "Security Group for public subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [ 
    {
      rule = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "smtp-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 1515
      to_port = 1515
      protocol = 6
      description = "Wazuh Agent enrollment via automatic agent request"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 1514
      to_port = 1514
      description = "Wazuh Agent comms"
      protocol = 6
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 55000
      to_port = 55000
      protocol = 6
      description = "Wazuh Agent enrollment via management API"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
    },
   ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

module "administrators-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "administrators-subnet-sg"
  description = "Security Group for public subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [ 
    {
      rule = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "ssh-tcp"
      cidr_blocks = "${module.bastion.private_ip}/32"
    },
    {
      from_port = 1515
      to_port = 1515
      protocol = 6
      description = "Wazuh Agent enrollment via automatic agent request"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 1514
      to_port = 1514
      description = "Wazuh Agent comms"
      protocol = 6
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 55000
      to_port = 55000
      protocol = 6
      description = "Wazuh Agent enrollment via management API"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
    },
   ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

module "finance-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "finance-subnet-sg"
  description = "Security Group for public subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [ 
    {
      from_port = 1515
      to_port = 1515
      protocol = 6
      description = "Wazuh Agent enrollment via automatic agent request"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 1514
      to_port = 1514
      description = "Wazuh Agent comms"
      protocol = 6
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 55000
      to_port = 55000
      protocol = 6
      description = "Wazuh Agent enrollment via management API"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
    },
   ]

  egress_cidr_blocks = concat(module.vpc.public_subnets_cidr_blocks, ["192.168.40.0/24"])
  egress_rules       = ["all-all"]

  create = var.create_other
  tags = local.tags
}

module "it-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "it-subnet-sg"
  description = "Security Group for public subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

    ingress_with_cidr_blocks = [ 
    {
      from_port = 1515
      to_port = 1515
      protocol = 6
      description = "Wazuh Agent enrollment via automatic agent request"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 1514
      to_port = 1514
      description = "Wazuh Agent comms"
      protocol = 6
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 55000
      to_port = 55000
      protocol = 6
      description = "Wazuh Agent enrollment via management API"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
    },
   ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  create = var.create_other
  tags = local.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "public_vms" {
  key_name   = "public-subnets"
  public_key = var.public_subnets_ssh_key
}

resource "aws_key_pair" "private_vms" {
  key_name   = "private-subnets"
  public_key = var.private_subnets_ssh_key
}

module "mail-server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "mail-server"

  instance_type               = var.instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.public_vms.key_name
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.public-sg.security_group_id]
  associate_public_ip_address = true

  create = var.create_other
  tags = local.tags
}

module "web-server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "web-server"

  instance_type               = var.instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.public_vms.key_name
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.public-sg.security_group_id]
  associate_public_ip_address = true

  create = var.create_other
  tags = local.tags
}

module "administrator-vms" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "administrator-vm"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.private_vms.key_name
  subnet_id              = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [module.administrators-sg.security_group_id]

  create = var.create_other
  tags = local.tags
}

module "net-monitor-vm" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "net-monitor-vm"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.private_vms.key_name
  subnet_id              = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [module.administrators-sg.security_group_id]

  create = var.create_other
  tags = local.tags
}

module "finance-vms" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "finance-vm"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.private_vms.key_name
  subnet_id              = element(module.vpc.private_subnets, 1)
  vpc_security_group_ids = [module.finance-sg.security_group_id]

  create = var.create_other
  tags = local.tags
}

module "it-vms" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "it-vm"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.private_vms.key_name
  subnet_id              = element(module.vpc.private_subnets, 2)
  vpc_security_group_ids = [module.it-sg.security_group_id]

  create = var.create_other
  tags = local.tags
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "bastion"

  instance_type               = "t2.xlarge"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.public_vms.key_name
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.public-sg.security_group_id]
  associate_public_ip_address = true

    ebs_block_device = [
    {
      device_name = "/dev/sda1"
      volume_type = "gp2"
      volume_size = 30
      encrypted   = false
    }
  ]

  tags = local.tags
}