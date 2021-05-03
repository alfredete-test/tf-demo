
resource "aws_vpc" "default" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "Default VPC"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet a"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet b"
  }
}


resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "Default VPC Internet Gateway"
  }
}

resource "aws_route_table" "public_subnet_rt" {
    vpc_id = aws_vpc.default.id

    route {
      gateway_id = aws_internet_gateway.vpc_igw.id
      cidr_block = "0.0.0.0/0"
    }

    tags = {
        Name = "Public Subnets Route Table for Default VPC"
    }
}

resource "aws_route_table_association" "subnet_public_a_tr" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_subnet_rt.id
}

resource "aws_route_table_association" "subnet_public_b_tr" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_subnet_rt.id
}




resource "aws_subnet" "private_subnet_1a" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Private Subnet ${var.region}a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "Private Subnet ${var.region}b"
  }
}


resource "aws_route_table" "private_subnet_rt_a" {
    vpc_id = aws_vpc.default.id

    route {
      nat_gateway_id = aws_nat_gateway.nat_gw_a.id
      cidr_block = "0.0.0.0/0"
    }

    tags = {
        Name = "Private Subnets Route Table for Default VPC"
    }
}

resource "aws_route_table_association" "subnet_private_tr_a" {
    subnet_id = aws_subnet.private_subnet_1a.id
    route_table_id = aws_route_table.private_subnet_rt_a.id
}

resource "aws_route_table" "private_subnet_rt_b" {
    vpc_id = aws_vpc.default.id

    route {
      nat_gateway_id = aws_nat_gateway.nat_gw_b.id
      cidr_block = "0.0.0.0/0"
    }

    tags = {
        Name = "Private Subnets Route Table for Default VPC"
    }
}


resource "aws_route_table_association" "subnet_private_tr_b" {
    subnet_id = aws_subnet.private_subnet_1b.id
    route_table_id = aws_route_table.private_subnet_rt_b.id
}

resource "aws_eip" "eip-nat_a" {
  vpc              = true
}



resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.eip-nat_a.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "gw NAT a"
  }
}

resource "aws_eip" "eip-nat_b" {
  vpc              = true
}



resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = aws_eip.eip-nat_b.id
  subnet_id     = aws_subnet.public_subnet_2.id

  tags = {
    Name = "gw NAT b"
  }
}


