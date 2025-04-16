terraform {
  source = "../../modules"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "unique-name-for-s3-dev"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "unique-name-for-s3-dev"
  }
}

inputs = {
  path          = "../../modules"
  name          = "dev-instance"
  environment   = "dev"
  instance_type = "t2.micro"
}
