resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }
}

resource "aws_subnet" "public-a" {
  availability_zone = "ap-northeast-2a"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "public-c" {
  availability_zone = "ap-northeast-2c"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "public-a" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.public-a.id
}

resource "aws_nat_gateway" "public-c" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.public-c.id
}

resource "aws_subnet" "private-a" {
  availability_zone = "ap-northeast-2a"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
}

resource "aws_subnet" "private-c" {
  availability_zone = "ap-northeast-2c"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
}

resource "aws_route_table" "private-a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public-a.id
  }
}

resource "aws_route_table" "private-c" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public-c.id
  }
}
