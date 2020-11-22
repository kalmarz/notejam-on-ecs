resource "aws_vpc" "ecs-main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "${var.APP}-${var.ENV}-ecs-vpc"
    App  = var.APP
  }
}

resource "aws_subnet" "main-public-1" {
  vpc_id                  = aws_vpc.ecs-main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "${var.APP}-${var.ENV}-ecs-public-1"
    App  = var.APP
  }
}

resource "aws_subnet" "main-public-2" {
  vpc_id                  = aws_vpc.ecs-main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "${var.APP}-${var.ENV}-ecs-public-2"
    App  = var.APP
  }
}

resource "aws_subnet" "main-public-3" {
  vpc_id                  = aws_vpc.ecs-main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1c"

  tags = {
    Name = "${var.APP}-${var.ENV}-ecs-public-3"
    App  = var.APP
  }
}

resource "aws_internet_gateway" "ecs-main-igw" {
  vpc_id = aws_vpc.ecs-main.id

  tags = {
    Name = "${var.APP}-${var.ENV}-ecs-igw"
    App  = var.APP
  }
}

resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.ecs-main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs-main-igw.id
  }

  tags = {
    Name = "${var.APP}-${var.ENV}-ecs-public-route-table"
    App  = var.APP
  }
}

resource "aws_route_table_association" "main-public-1" {
  subnet_id      = aws_subnet.main-public-1.id
  route_table_id = aws_route_table.main-public.id
}

resource "aws_route_table_association" "main-public-2" {
  subnet_id      = aws_subnet.main-public-2.id
  route_table_id = aws_route_table.main-public.id
}

resource "aws_route_table_association" "main-public-3" {
  subnet_id      = aws_subnet.main-public-3.id
  route_table_id = aws_route_table.main-public.id
}
