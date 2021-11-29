resource "aws_key_pair" "ssh-key" {

  key_name   = "ssh-key"
  public_key = file(var.public_key_path)

}

variable "ami_host" {
}

resource "aws_instance" "example" {

  ami           = var.ami_host
  instance_type = "t2.micro"
 
  subnet_id = var.sub

  associate_public_ip_address = true

  key_name         = "ssh-key"

  vpc_security_group_ids = [aws_security_group.allow_ports.id]

  # small test...
 
  provisioner "remote-exec" {

   inline = ["echo I am in ",
              "hostname",
              "python3 --version",
              "sleep 10",
              "sudo apt update",
              "sleep 5",
              "sudo apt install -y wget"
            ]
             

   connection {

    type = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host = aws_instance.example.public_ip
   } 
  }


  tags = {
    Name = "PackerInstance"
  }

}
