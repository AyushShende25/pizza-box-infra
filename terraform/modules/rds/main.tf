resource "aws_db_subnet_group" "db" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    { Name = var.db_subnet_group_name }
  )
}

resource "aws_db_instance" "db" {
  identifier              = var.db_identifier
  db_subnet_group_name    = aws_db_subnet_group.db.name
  allocated_storage       = var.allocated_storage
  storage_type            = "gp3"
  db_name                 = var.db_name
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  multi_az                = true
  publicly_accessible     = false
  storage_encrypted       = true
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period
  vpc_security_group_ids  = var.vpc_security_group_ids

  tags = var.tags
}
