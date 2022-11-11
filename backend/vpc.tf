resource "aws_vpc" "jungle-meet" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "jungle-meet-be-public-01" {
  vpc_id     = aws_vpc.jungle-meet.id
  cidr_block = "10.1.1.0/24"

  availability_zone = var.az_1
}

resource "aws_subnet" "jungle-meet-be-public-02" {
  vpc_id     = aws_vpc.jungle-meet.id
  cidr_block = "10.1.2.0/24"

  availability_zone = var.az_2
}

resource "aws_subnet" "jungle-meet-be-private-01" {
  vpc_id     = aws_vpc.jungle-meet.id
  cidr_block = "10.1.3.0/24"

  availability_zone = var.az_1
}

resource "aws_subnet" "jungle-meet-be-private-02" {
  vpc_id     = aws_vpc.jungle-meet.id
  cidr_block = "10.1.4.0/24"

  availability_zone = var.az_2
}

# Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.jungle-meet.id
}


# Net gateway
# resource "aws_nat_gateway" "gw" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.jungle-meet-be-public-01.id

#   depends_on = [aws_internet_gateway.gw]
# }

resource "aws_eip" "nat" {
  vpc              = true
  public_ipv4_pool = "amazon"
}

# routing tables
resource "aws_route_table" "jungle-meet-public" {
  vpc_id = aws_vpc.jungle-meet.id

  # route {
  #   cidr_block = "10.1.0.0/16"
  #   gateway_id = aws_internet_gateway.main.id
  # }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "jungle-meet-public_public-01" {
  subnet_id      = aws_subnet.jungle-meet-be-public-01.id
  route_table_id = aws_route_table.jungle-meet-public.id
}

resource "aws_route_table_association" "jungle-meet-public_public-02" {
  subnet_id      = aws_subnet.jungle-meet-be-public-02.id
  route_table_id = aws_route_table.jungle-meet-public.id
}

resource "aws_route_table" "jungle-meet-private" {
  vpc_id = aws_vpc.jungle-meet.id

  # route {
  #   cidr_block = "10.1.0.0/16"
  #   gateway_id = aws_internet_gateway.main.id
  # }

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.gw.id
  # }
}

resource "aws_route_table_association" "jungle-meet-public_private-01" {
  subnet_id      = aws_subnet.jungle-meet-be-private-01.id
  route_table_id = aws_route_table.jungle-meet-private.id
}

resource "aws_route_table_association" "jungle-meet-public_private-02" {
  subnet_id      = aws_subnet.jungle-meet-be-private-02.id
  route_table_id = aws_route_table.jungle-meet-private.id
}
