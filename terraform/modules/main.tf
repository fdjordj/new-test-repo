resource "aws_instance" "ec2" {
  ami           = "ami-0b0ea68c435eb488d" 
  instance_type = var.instance_type

  tags = {
    Name = var.name
    Env  = var.environment
  }
}

terraform {
  backend "s3" {}
}