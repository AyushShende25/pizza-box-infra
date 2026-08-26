output "endpoint" {
  value = aws_db_instance.db.endpoint
}

output "address" {
  value = aws_db_instance.db.address
}

output "port" {
  value = aws_db_instance.db.port
}

output "db_name" {
  value = aws_db_instance.db.db_name
}
