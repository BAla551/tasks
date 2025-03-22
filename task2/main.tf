provider "aws" {
  region = "ap-south-1"
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone  = "ap-south-1a"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.7.0/24"
  availability_zone  = "ap-south-1b"
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances in Private Subnets
resource "aws_instance" "ec2_1" {
  ami                    = "ami-0e35ddab05955cf57" # Change to your preferred AMI
  instance_type          = "t2.micro"
  subnet_id             = aws_subnet.private_subnet_1.id
  security_groups       = [aws_security_group.ec2_sg.id]
  key_name              = "task" # Change to your key pair

  user_data = <<-EOF
              #!/bin/bash
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker run -d -p 8080:8080 --name my-container nginx:alpine sh -c "echo 'Namaste from Container' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"
              EOF
}

resource "aws_instance" "ec2_2" {
  ami                    = "ami-0e35ddab05955cf57" # Change to your preferred AMI
  instance_type          = "t2.micro"
  subnet_id             = aws_subnet.private_subnet_2.id
  security_groups       = [aws_security_group.ec2_sg.id]
  key_name              = "task" # Change to your key pair
}

# Elastic IPs for Domain Mapping
resource "aws_eip" "eip_1" {
  instance = aws_instance.ec2_1.id
  depends_on = [aws_instance.ec2_1]
}

resource "aws_eip" "eip_2" {
  instance = aws_instance.ec2_2.id
  depends_on = [aws_instance.ec2_2]
}

# ALB for Load Balancing
resource "aws_lb" "alb" {
  name               = "ec2-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]
  subnets           = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "ec2-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-south-1:123456789012:certificate/your-cert-id" # Replace with your SSL certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment_1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2_1.id
  port            = 8080
}

resource "aws_lb_target_group_attachment" "tg_attachment_2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2_2.id
  port            = 8080
}
