variable "project" { type = string, default = "full-demo" }
variable "region"  { type = string, default = "eu-west-3" }

variable "azs" { type = list(string), default = ["eu-west-3a","eu-west-3b"] }
variable "vpc_cidr" { type = string, default = "10.30.0.0/16" }
variable "public_subnet_cidrs"  { type = list(string), default = ["10.30.0.0/24","10.30.1.0/24"] }
variable "private_subnet_cidrs" { type = list(string), default = ["10.30.100.0/24","10.30.101.0/24"] }

variable "create_nat_per_az" { type = bool, default = false }

variable "key_pair_name" { type = string, default = "ma-cle-aws" }
variable "instance_type" { type = string, default = "t3.micro" }
variable "allowed_ssh_cidr" { type = string, default = "0.0.0.0/0" }
variable "create_bastion" { type = bool, default = true }

variable "bucket_name" { type = string, default = "full-demo-bucket-123456" }

variable "db_username" { type = string,  default = "admin" }
variable "db_password" { type = string,  sensitive = true, default = "Password123!" }
variable "db_name"     { type = string,  default = "appdb" }
variable "db_instance_class" { type = string, default = "db.t3.micro" }
variable "allocated_storage" { type = number, default = 20 }