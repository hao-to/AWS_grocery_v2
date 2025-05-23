output "ec2_public_ip" {
  value = aws_instance.grocerymate_ec2.public_ip
}

output "rds_endpoint" {
  description = "The endpoint of the RDS PostgreSQL instance"
  value       = aws_db_instance.grocerymate_rds.endpoint
}
