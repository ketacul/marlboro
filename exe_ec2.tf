# AMI Amazon Linux 2023 x86_64
data "aws_ami" "al2023" {
  most_recent = true
  owners = ["137112412989"] # Amazon
  filter { name="name", values=["al2023-ami-*-x86_64"] }
}

# Bastion (public)
resource "aws_instance" "bastion" {
  count = var.create_bastion ? 1 : 0
  ami = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  subnet_id = values(aws_subnet.public)[0].id
  key_name = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = { Name="${var.project}-bastion", Project=var.project }
}

# App (privé) — écoute sur 8080, lit S3, affiche endpoint RDS
resource "aws_instance" "app" {
  ami = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id = values(aws_subnet.private)[0].id
  key_name = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf -y update
    dnf -y install nginx jq
    systemctl enable nginx
    systemctl start nginx
    echo "OK" > /usr/share/nginx/html/health
    BUCKET="${var.bucket_name}"
    RDS_ENDPOINT="${aws_db_instance.mysql.endpoint}"
    echo "<h1>App privée</h1><p>Bucket: $BUCKET</p><p>RDS: $RDS_ENDPOINT</p>" > /usr/share/nginx/html/index.html
    # Exemple d'accès S3 (listing)
    dnf -y install awscli
    aws s3 ls s3://$BUCKET/ > /usr/share/nginx/html/s3-list.txt || true
  EOF

  tags = { Name="${var.project}-app", Project=var.project }
}