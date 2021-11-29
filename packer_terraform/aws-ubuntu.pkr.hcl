packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name              = "12learn-packer-linux-aws"
  vpc_id		= "vpc-0568318aae417c65b"
  subnet_id		= "subnet-071fb032d5be89f49"
  ssh_keypair_name     = "key-pair-example"
  ssh_private_key_file = "/root/.aws/pems/key-pair-example.pem"
  instance_type        = "t2.micro"
  region               = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}

