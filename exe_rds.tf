resource "aws_db_subnet_group" "rds_subnets" {
  name = "${var.project}-rds-subnets"
  subnet_ids = [for s in aws_subnet.private : s.id]
  tags = { Name="${var.project}-rds-subnets", Project=var.project }
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.project}-mysql"
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
  storage_type = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az = false
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
  deletion_protection = false
  skip_final_snapshot = true

  tags = { Name="${var.project}-rds", Project=var.project }
}