resource "aws_security_group" "lb" {
  name        = "pizzabox-alb"
  description = "Allow HTTP traffic from Internet"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { Name = "pizzabox-alb" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "lb_https_ipv4" {
  security_group_id = aws_security_group.lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "lb_http_ipv4" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "lb_egress_ipv4" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_security_group" "eks" {
  name        = "pizzabox-eks-node"
  description = "Allow HTTP traffic exclusively from Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { Name = "pizzabox-eks-node" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "eks_from_lb" {
  security_group_id            = aws_security_group.eks.id
  referenced_security_group_id = aws_security_group.lb.id
  from_port                    = var.api_port
  to_port                      = var.api_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "eks" {
  security_group_id = aws_security_group.eks.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "db" {
  name        = "pizzabox-db"
  description = "Database access from EKS"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "pizzabox-db" })
}

resource "aws_vpc_security_group_ingress_rule" "db_from_eks" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.eks.id
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "redis" {
  name        = "pizzabox-redis"
  description = "Redis access from EKS"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "pizzabox-redis" })
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_eks" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.eks.id
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  ip_protocol                  = "tcp"
}
