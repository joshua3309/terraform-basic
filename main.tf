provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "aws" {
  region = "ap-southeast-1"
  alias  = "singapore"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  providers = {
    aws = aws.singapore
  }
  name = "devops-demo"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  map_public_ip_on_launch = true
  public_subnet_suffix = "devopsdemopubsub"
  private_subnet_suffix = "devopsdemopvtsub"
  
  public_subnet_tags = {
    Name = "devopsdemo-pub"
  }

  tags = {
    Owner =       "joshua"
    Environment = "dev"  
  }
  
  vpc_tags = {
    Name = "devop-demo"
  }

}

data aws_db_instance database {
  provider = aws.singapore
  db_instance_identifier = var.rds_name
}
resource "aws_instance" "frontend" {
  count    = var.ec2-count
  provider = aws.singapore

  ami                     = var.ami
  instance_type           = var.instance["type"]
  key_name                = var.key["name"]
  disable_api_termination = false
  vpc_security_group_ids  = [aws_security_group.frontend.id]
  subnet_id               = module.vpc.public_subnets[0]

  provisioner "file" {
    source      = "user-data.sh"
    destination = "/home/ubuntu/user-data.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("terraform-ap")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {

    inline = [
      "chmod +x /home/ubuntu/user-data.sh",
      "/home/ubuntu/user-data.sh" 
    ]   
 

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("terraform-ap")
      host        = self.public_ip
    }
  }

  tags = {
    Name       = var.tags["name"]
    App        = var.tags["app"]
    Maintainer = var.tags["maintainer"]
    Role       = var.tags["role"]
  }

  depends_on = [aws_key_pair.terraform]

  lifecycle {
    prevent_destroy = false
  }

  timeouts {
    create = "7m"
    delete = "1h"
  }

}

resource "aws_key_pair" "terraform" {
  provider   = aws.singapore
  key_name   = var.key["name"]
  public_key = var.key["pub"]
}

resource "aws_security_group" "frontend" {
  name        = "frontend"
  vpc_id      = module.vpc.vpc_id
  description = "security config for frontend"
  provider    = aws.singapore

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "open to all port"
  }
 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "open to http traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all out going connections"
  }

  tags = {
    role = var.tags["role"]
    app  = var.tags["app"]
  }

}

resource "null_resource" "populate_db_01" {

  triggers = {
    rds_instance_id = data.aws_db_instance.database.endpoint
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e \"s/DBHOST/${data.aws_db_instance.database.address}/g\" /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e \"s/SQLUSER/${data.aws_db_instance.database.master_username}/g\" /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e \"s/SQLPASSWORD/${var.rds_pass}/g\" /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e \"s/SQLDBNAME/${data.aws_db_instance.database.db_name}/g\" /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo service apache2 restart'"
  }
}
