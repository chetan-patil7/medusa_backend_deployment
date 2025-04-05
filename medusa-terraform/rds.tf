resource "aws_db_subnet_group" "medusa_db" {
  name       = "medusa-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "Medusa DB subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "medusa-rds-sg"
  description = "Allow inbound traffic from ECS"
  vpc_id      = aws_vpc.medusa_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "medusa_db" {
  identifier             = "medusa-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.7"
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.medusa_db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name   = "default.postgres13"
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = true
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "medusa-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}
