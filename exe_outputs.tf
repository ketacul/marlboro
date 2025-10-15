output "vpc_id"            { value = aws_vpc.main.id }
output "public_subnets"    { value = { for k,s in aws_subnet.public : k => s.id } }
output "private_subnets"   { value = { for k,s in aws_subnet.private: k => s.id } }

output "bastion_public_ip" { value = try(aws_instance.bastion[0].public_ip, null) }
output "app_private_ip"    { value = aws_instance.app.private_ip }
output "ssh_bastion" {
  value = try("ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.bastion[0].public_ip}", null)
}

output "rds_endpoint"      { value = aws_db_instance.mysql.endpoint }
output "db_name"           { value = aws_db_instance.mysql.db_name }
output "s3_bucket"         { value = aws_s3_bucket.main.bucket }