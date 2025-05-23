variable "db_password" {
  description = "Password for the RDS postgres user"
  type        = string
  sensitive   = true
}
