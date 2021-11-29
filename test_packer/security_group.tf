resource "aws_security_group" "allow_ports" {

  name        = "allow_ports"
  description = "inbound and outbound traffic"


 
  dynamic "ingress" {
    for_each = toset(var.iportz)
      content {
         from_port = ingress.value
         to_port = ingress.value
         protocol = "6"
         cidr_blocks = ["0.0.0.0/0"]
       }
    }


    dynamic "egress" {
    for_each = toset(var.eportz)
      content {
         from_port = egress.value
         to_port = egress.value
         protocol = "6"
         cidr_blocks = ["0.0.0.0/0"]
       }
    }


  vpc_id = var.uvpc

}
