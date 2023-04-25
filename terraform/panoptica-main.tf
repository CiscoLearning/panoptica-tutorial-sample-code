##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

##################################################################################
# DATA
##################################################################################

data "aws_ami" "ubuntu-linux" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


##################################################################################
# RESOURCES
##################################################################################

#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "allow_panoptica" {
  name        = "panoptica-security-group"
  description = "Allow ports for Panoptica tutorial"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "panoptica-tutorial" {
  ami                    = data.aws_ami.ubuntu-linux.id
  instance_type          = "c5a.8xlarge"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_panoptica.id]
  tags = {
    Name = "panoptica-tutorial"
  }

  root_block_device {
    volume_size           = 75
    volume_type           = "gp2"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

provisioner "file" {
    source      = "./prereq_setup.sh"
    destination = "/tmp/prereq_setup.sh"
  }

provisioner "file" {
    source      = "./panoptica.tar.gz"
    destination = "/home/ubuntu/panoptica.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "tar xvzf ~/panoptica.tar.gz",
      "chmod +x /tmp/prereq_setup.sh",
      "bash /tmp/prereq_setup.sh"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = aws_instance.panoptica-tutorial.public_dns
}

# Save external IP/DNS address of instance
resource "local_file" "ip-address" {
  filename = "${aws_instance.panoptica-tutorial.public_dns}.info"
  content  = aws_instance.panoptica-tutorial.public_dns
}