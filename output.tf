output "hostname" {
  value = aws_instance.frontend.*.public_dns
}

output "ip" {
  value = aws_instance.frontend.*.public_ip
}

output "ssh_key" {
  value = aws_instance.frontend.*.key_name
}

output "rds_endpoint" {
  value = data.aws_db_instance.database.endpoint
}

output "rds-db" {
  value = data.aws_db_instance.database.db_name
}

output "rds_engine" {
  value = data.aws_db_instance.database.engine
}
