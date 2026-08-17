resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy

  tags = var.tags
}

resource "aws_subnet" "subnet" {
  for_each = var.subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = merge(
    var.tags,
    {
      Name = each.key
    }
  )
}

locals {
  public_subnets = {
    for k, v in var.subnets : k => v
    if v.type == "public"
  }
  application_subnets = {
    for k, v in var.subnets : k => v
    if v.type == "application"
  }
  database_subnets = {
    for k, v in var.subnets : k => v
    if v.type == "database"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, { Name = "${lookup(var.tags, "Name", "vpc")}-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.tags,
    { Name = "public-rt" }
  )
}

resource "aws_route_table_association" "public" {
  for_each  = local.public_subnets
  subnet_id = aws_subnet.subnet[each.key].id

  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat" {
  for_each = local.public_subnets
  domain   = "vpc"
  tags = merge(var.tags, {
    Name = "eip-${each.key}"
  })
}

resource "aws_nat_gateway" "nat" {
  for_each = local.public_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnet[each.key].id

  tags = merge(
    var.tags,
    { Name = "nat-gw-${each.key}" }
  )

  depends_on = [aws_internet_gateway.gw]
}


# nat_gateway_by_az = {
#   "ap-south-1a" = "nat-111"
#   "ap-south-1b" = "nat-222"
# }
locals {
  nat_gateway_by_az = {
    for key, subnet in local.public_subnets : subnet.availability_zone => aws_nat_gateway.nat[key].id
  }
}


resource "aws_route_table" "application" {
  for_each = local.application_subnets
  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = local.nat_gateway_by_az[
      each.value.availability_zone
    ]
  }

  tags = merge(
    var.tags,
    { Name = "rt-${each.key}" }
  )
}

resource "aws_route_table_association" "application" {
  for_each  = local.application_subnets
  subnet_id = aws_subnet.subnet[each.key].id

  route_table_id = aws_route_table.application[each.key].id
}

resource "aws_route_table" "database" {
  for_each = local.database_subnets
  vpc_id   = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    { Name = "rt-${each.key}" }
  )
}

resource "aws_route_table_association" "database" {
  for_each  = local.database_subnets
  subnet_id = aws_subnet.subnet[each.key].id

  route_table_id = aws_route_table.database[each.key].id
}
