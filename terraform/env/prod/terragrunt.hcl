terraform {
  source = "../../../modules"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "unique-name-for-s3-prod"
    key            = "prod/ec2/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "unique-name-for-s3-prod"
  }
}

inputs = {
  name          = "prod-instance"
  environment   = "prod"
  instance_type = "t2.micro"
}
