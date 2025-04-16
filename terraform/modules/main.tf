variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" 
  instance_type = var.instance_type

  tags = {
    Name = var.name
    Env  = var.environment
  }
}
