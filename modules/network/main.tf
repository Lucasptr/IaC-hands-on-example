resource "aws_vpc" "terraform_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.prefix}-terraform-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "terraform_subnets" {
  count             = length(var.subnet_cidr_blocks)
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  # for_each         = toset(var.subnet_cidr_blocks)
  # cidr_block        = each.key
  # availability_zone = data.aws_availability_zones.available.names[lookup(var.subnet_availability_zones, each.key, 0) % length(data.aws_availability_zones.available.names)]   

  tags = {
    Name = "${var.prefix}-terraform-subnet-${count.index}"
    # Name = "${var.prefix}-terraform-subnet-${each.key}"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id
}

resource "aws_route_table" "terraform_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
}

resource "aws_route_table_association" "terraform_route_table_association" {
  count = length(var.subnet_cidr_blocks)
  #for_each       = toset(var.subnet_cidr_blocks)
  subnet_id      = aws_subnet.terraform_subnets[count.index].id
  route_table_id = aws_route_table.terraform_route_table.id
}

resource "aws_security_group" "terraform_security_group" {
  vpc_id      = aws_vpc.terraform_vpc.id
  name        = "${var.prefix}-allow-ssh"
  description = "Allow SSH"

  tags = {
    Name = "${var.prefix}-terraform-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "terraform_sg_ssh_ingress_rule" {
  security_group_id = aws_security_group.terraform_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "terraform_sg_http_ingress_rule" {
  security_group_id = aws_security_group.terraform_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "terraform_security_group_egress_rule" {
  security_group_id = aws_security_group.terraform_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
