##Creating VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "challenge_vpc"
  }
}

##Creating Internet Gateway and attaching it with VPC

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "challenge_igw"
  }
}

##Creating two subnets for high availability

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zone, count.index) 
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}


resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zone, count.index) 
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index+1}"
  }
}


##Creating route tables for each subnet types i.e public and private

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "challenge_public_RT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "challenge_private_RT"
  }
}

##Associating the route tables with the subnets
resource "aws_route_table_association" "public_subnet_association" {
  count = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}



##Associating Internet Gateway to the public route table routes

resource "aws_route" "public_internet_gateway" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}

##Creating Nat Gateway and associating it with the private route table

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [
    aws_eip.nat,
    aws_route_table_association.private_subnet_association,
  ]
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route" "private_nat_gateway" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat.id
}
