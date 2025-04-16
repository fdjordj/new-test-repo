resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-s3-bucket-name"  
  region = "us-east-1"  
  tags = {
    Name        = "MyS3Bucket"
    Environment = "Production"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0b0ea68c435eb488d"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.alb_sg.id]

 user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y nginx
              echo 'server {
                      listen 80;
                      server_name _;

                      location / {
                          proxy_pass http://<NLB_DNS>;
                          proxy_http_version 1.1;
                          proxy_set_header Upgrade $http_upgrade;
                          proxy_set_header Connection 'upgrade';
                          proxy_set_header Host $host;
                          proxy_cache_bypass $http_upgrade;
                      }
                    }' > /etc/nginx/sites-available/default

              systemctl restart nginx
              EOF

  tags = {
    Name = "nginx-reverse-proxy"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "80"
  }
}

resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}