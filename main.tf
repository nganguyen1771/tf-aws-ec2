provider "aws" {
  region  = "ap-southeast-1"
  shared_credentials_files = ["~/.aws/session_token"]
//  dev
  assume_role {
    role_arn = "arn:aws:iam::<account-id>:role/infras_admin"
  }
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.18.2"
  cidr_block = "172.16.0.0/16"
  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.0.2"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block           = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}
module "aws_key_pair" {
  source              = "cloudposse/key-pair/aws"
  version             = "0.18.3"
  //ssh_public_key_path = var.ssh_public_key_path
  ssh_public_key_path = "${path.cwd}"
  generate_ssh_key    = true

  context = module.this.context
}

module "security_group" {
  source = "cloudposse/security-group/aws"
  version = "1.0.1"
  attributes = ["primary"]
  name = "sg"
  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "post"
      type        = "ingress"
      from_port   = 8065
      to_port     = 8065
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      self        = null
      description = ""
    },
  ]
  vpc_id  = module.vpc.vpc_id
  context = module.this.context
}

module "ec2_instance" {
  source = "cloudposse/ec2-instance/aws"

  ssh_key_pair                = module.aws_key_pair.key_name
  vpc_id                      = module.vpc.vpc_id
  subnet                      = module.subnets.public_subnet_ids[0]
  security_groups             = [module.vpc.vpc_default_security_group_id,module.security_group.id]
  assign_eip_address          = var.assign_eip_address
  associate_public_ip_address = var.associate_public_ip_address
  instance_type               = var.instance_type
  security_group_rules        = var.security_group_rules
   
  context = module.this.context
  name = "ec2"
  
}

resource "null_resource" "demo" {
  connection {
    type  = "ssh"
    host  = module.ec2_instance.public_ip
    user  = var.ssh_user
    port  = var.ssh_port
    private_key = file(pathexpand("${module.aws_key_pair.key_name}"))
    agent = true
  }
  provisioner "file" {
    source      = "./init-config.sh"
    destination = "./init-config.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt install -y docker.io",
      "sudo apt install -y pass",
      "sudo rm -f /usr/local/bin/docker-compose && sudo curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo rm -f /usr/bin/docker-compose && sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "sudo /bin/bash init-config.sh",
    ]
  }
}

