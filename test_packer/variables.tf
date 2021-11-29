variable "private_key_path" {
  #change accordingly
  default = "/root/.ssh/id_rsa"
}

variable "public_key_path" {
  # change accordingly
  default = "/root/.ssh/id_rsa.pub"
}

variable "uregion" {
  # change accordingly
  default = "us-east-2"
}

variable "uvpc" {
  # change accordingly
  default = "vpc-0568318aae417c65b"
}

variable "sub" {
  # change accordingly
  default = "subnet-071fb032d5be89f49"
}
variable "iportz" {
  default = [22,3306,33060]
}

variable "eportz" {
  default = [80,443]
}
