locals {
    name_prefix = "${var.env}-${var.region}"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.cidr_block_vpc
  region =  var.region
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "acme-inc-${local.name_prefix}"
  }
}

resource "aws_subnet" "my_public_subnet" {
  for_each = var.cidr_block_Public_subnet
  vpc_id              = aws_vpc.my_vpc.id
  availability_zone   = each.value.az
  cidr_block = each.value.cidr
  map_public_ip_on_launch = true
  region = var.region

  tags = {
    Name = "acme-inc-${local.name_prefix}-public-subnet-${each.key}"
  }
}

resource "aws_subnet" "my_private_subnet" {
  for_each = var.cidr_block_Public_subnet
  vpc_id              = aws_vpc.my_vpc.id
  availability_zone   = each.value.az
  cidr_block = each.value.cidr
  region = var.region

  tags = {
    Name = "acme-inc-${local.name_prefix}-private-subnet-${each.key}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "acme-inc-${local.name_prefix}-igw"
  }
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "acme-inc-${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "my_public_rtas" {
  for_each = aws_subnet.my_public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.my_public_route_table.id

  depends_on = [ aws_internet_gateway.my_igw ]
}

resource "aws_eip" "nat_ip" {
    for_each = aws_subnet.my_public_subnet
    domain = "vpc"
}

resource "aws_nat_gateway" "my_nat_gateway" {
  for_each = aws_subnet.my_public_subnet
  allocation_id = aws_eip.nat_ip[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "acme-inc-${local.name_prefix}-nat-gateway-${each.key}"
  }
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_route_table" "my_private_route_table" {
  for_each = var.cidr_block_Private_subnet
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "acme-inc-${local.name_prefix}-private-rt-${each.key}"
  }
}

resource "aws_route" "private_nat" {
  for_each = aws_route_table.my_private_route_table
  route_table_id = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my_nat_gateway[each.key].id

  depends_on = [ aws_nat_gateway.my_nat_gateway ]
}

resource "aws_route_table_association" "my_private_rta" {
  for_each = aws_subnet.my_private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.my_private_route_table[each.key].id

}

resource "aws_security_group" "sg" {
  name = "acme-inc-${local.name_prefix}-sg"
  vpc_id = aws_vpc.my_vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow-ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow-http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name = "acme-inc-${local.name_prefix}-private-sg"
  vpc_id = aws_vpc.my_vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow-ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.sg.id]
  }
  ingress {
    description = "allow-http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.sg.id]
  }
}

resource "aws_security_group" "db_sg" {
  name = "acme-inc-${local.name_prefix}-db-sg"
  vpc_id = aws_vpc.my_vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow-db-access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [aws_security_group.private_sg.id]
  }

}