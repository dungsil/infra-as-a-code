# VPC
resource "aws_vpc" "vpc_bitwarden" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "${var.tag} VPC"
    Project = var.tag
  }
}

# Subnet
resource "aws_subnet" "sn_bitwarden" {
  vpc_id     = aws_vpc.vpc_bitwarden.id
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag} Subnet"
    Project = var.tag
  }
}

# Internet gateway
resource "aws_internet_gateway" "ig_bitwarden" {
  vpc_id = aws_vpc.vpc_bitwarden.id

  tags = {
    Name = "${var.tag} Internet Gateway"
    Project = var.tag
  }
}

# Routing table
resource "aws_default_route_table" "rt_bitwarden" {
  default_route_table_id = aws_vpc.vpc_bitwarden.default_route_table_id

  tags = {
    Name = "${var.tag} Route table"
    Project = var.tag
  }
}

# 라우팅 테이블 규칙 추가
resource "aws_route" "rtr_bitwarden" {
  route_table_id = aws_default_route_table.rt_bitwarden.default_route_table_id
  gateway_id = aws_internet_gateway.ig_bitwarden.id
  destination_cidr_block = "0.0.0.0/0"
}

# 퍼블릭 서브넷 - 라우팅테이블 연결
resource "aws_route_table_association" "rta_bitwarden" {
  route_table_id = aws_default_route_table.rt_bitwarden.default_route_table_id
  subnet_id = aws_subnet.sn_bitwarden.id
}

resource "aws_default_network_acl" "acl_bitwarden" {
  default_network_acl_id = aws_vpc.vpc_bitwarden.default_network_acl_id
  subnet_ids = [aws_subnet.sn_bitwarden.id]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.tag} ACL"
    Project = var.tag
  }
}

# 네트워크 인터페이스
resource "aws_network_interface" "nic_bitwarden" {
  subnet_id = aws_subnet.sn_bitwarden.id

  security_groups = [
    aws_security_group.sg_bitwarden.id
  ]

  tags = {
    Name = "${var.tag} NIC"
    Project = var.tag
  }
}

# 보안그룹
resource "aws_security_group" "sg_bitwarden" {
  name = "bitwarden"
  vpc_id = aws_vpc.vpc_bitwarden.id

  ingress {
    protocol = "TCP"
    from_port = 443
    to_port   = 443
    self = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port   = 0
    self = true
  }

  tags = {
    Name = "${var.tag} Security Group"
    Project = var.tag
  }
}
