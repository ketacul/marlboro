# Bastion/public
resource "aws_security_group" "bastion_sg" {
  name = "${var.project}-sg-bastion"
  vpc_id = aws_vpc.main.id
  tags = { Name="${var.project}-sg-bastion", Project=var.project }
}
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4 = var.allowed_ssh_cidr
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

# App (privé)
resource "aws_security_group" "app_sg" {
  name = "${var.project}-sg-app"
  vpc_id = aws_vpc.main.id
  tags = { Name="${var.project}-sg-app", Project=var.project }
}
# HTTP app interne depuis bastion (ou ALB si tu en ajoutes un)
resource "aws_vpc_security_group_ingress_rule" "app_from_bastion_http" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port = 8080
  to_port   = 8080
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

# DB (privé)
resource "aws_security_group" "db_sg" {
  name = "${var.project}-sg-db"
  vpc_id = aws_vpc.main.id
  tags = { Name="${var.project}-sg-db", Project=var.project }
}
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port = 3306
  to_port   = 3306
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}