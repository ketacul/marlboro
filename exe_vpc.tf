resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project}-vpc", Project = var.project }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project}-igw", Project = var.project }
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = { for i,c in var.public_subnet_cidrs : i => { cidr=c, az=var.azs[i] } }
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true
  tags = { Name="${var.project}-public-${each.value.az}", Tier="public", Project=var.project }
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = { for i,c in var.private_subnet_cidrs : i => { cidr=c, az=var.azs[i] } }
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = false
  tags = { Name="${var.project}-private-${each.value.az}", Tier="private", Project=var.project }
}

# Public RTB + route internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Name="${var.project}-rtb-public", Project=var.project }
}
resource "aws_route" "public_inet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT(s)
resource "aws_eip" "nat" {
  count = var.create_nat_per_az ? length(var.azs) : 1
  domain = "vpc"
  tags = { Name="${var.project}-nat-eip-${count.index}", Project=var.project }
}
resource "aws_nat_gateway" "nat" {
  count = var.create_nat_per_az ? length(var.azs) : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = values(aws_subnet.public)[var.create_nat_per_az ? count.index : 0].id
  depends_on = [aws_internet_gateway.igw]
  tags = { Name="${var.project}-nat-${count.index}", Project=var.project }
}

# Private RTB(s) + route via NAT
resource "aws_route_table" "private" {
  count = var.create_nat_per_az ? length(var.azs) : 1
  vpc_id = aws_vpc.main.id
  tags = { Name="${var.project}-rtb-private-${count.index}", Project=var.project }
}
resource "aws_route" "private_out" {
  count = var.create_nat_per_az ? length(var.azs) : 1
  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[count.index].id
}
resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = var.create_nat_per_az ?
    aws_route_table.private[index(keys(aws_subnet.private), each.key)].id :
    aws_route_table.private[0].id
}