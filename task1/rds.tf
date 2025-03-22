resource "aws_db_instance" "db" {
  identifier            = "wp-mariadb"
  engine               = "mariadb"
  instance_class       = var.db_instance_type
  allocated_storage    = 20
  db_name              = var.db_name
  username            = var.db_user
  password            = var.db_password
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  skip_final_snapshot = true
}

resource "aws_security_group" "db_sg" {
  name        = "db-security-group"
  description = "Allow inbound access to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}