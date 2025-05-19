# 1 Define the AWS provider and region
provider "aws" {
  region = "eu-central-1"
}

# 2 Load the default VPC (needed for the security group)
data "aws_vpc" "default" {
  default = true
}

# 3 Define SSH key pair for EC2 access
resource "aws_key_pair" "grocerymate_key" {
  key_name = "grocerymate-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6fYaERv8qcZOLyKKDJ0fFXj+mbqW9RfW28PmRm6KXLV5miVgpasf4iei1AVMg6aLG0UJg3KaaIj4qCJl5oZns8imnuyDhPOOlENpkqSxveL4gE6fXtpF/xuljH1+u5Cpue/coejkFdN5Z+1SH9cQI2FCHu3N7zPdc/hl7/lpSOTkQFBquVwV9nR8WLWJW9emohjqQSmxq0m5YWf7wjE16e1Q9obKQxklSjIPsP08AARFOBF+CS9SLN/rHpkD3z/piA7lrCFXtuzfL5WdbtKZ+oKPCowndLKvQ0BHVPdaIzS9l12YLekhXukRLaYi/a6QZaJvXTO21kc8O3/hl0YaqBfzoW4wGAYz6PYDhhd7oLDjiBAeknsmmNEoVZhfRiVZuTzWNDuzEVuk5zx70EAnHxKXI6UVqPdaMsX5fSATe6DEcz0iD7tbrOvLJWwCctqotcpxihTMtTKC+A07Svv3mzw69f8AXrq6Hw8jaS++pYqAjbG8CbCZiCbHyT2QMaHIKMzdITWsNV+a0RuTpgkeTFobspalxpnXDU2AwIzyTzboLrDrpSRtPJiEeMTnIP+t3O0qxRoM4m8eViLB9ojWFSYT857eYakpLCqKeuPc9/tkAnifs6T+tM/HLqPJ+B0cTg4WbdmbUoH1b25VfUro3JJuq1CvySAOf1XBgPqV5Gw== grocerymate"
}

# 4 Define a security group for EC2 that allows SSH access (port 22)
resource "aws_security_group" "grocerymate_sg" {
  name        = "grocerymate-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["78.54.164.215/32"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grocerymate-sg"
  }
}

# 5 Create an EC2 instance and attach the security group
resource "aws_instance" "grocerymate_ec2" {
  ami = "ami-02b7d5b1e55a7b5f1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.grocerymate_sg.id]
  key_name = aws_key_pair.grocerymate_key.key_name

  tags = {
    Name = "grocerymate-ec2"
  }
}

# 6 Define a security group for RDS that only allows connections from EC2
resource "aws_security_group" "grocerymate_rds_sg" {
  name        = "grocerymate-rds-sg"
  description = "Allow PostgreSQL access from EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Access from EC2 to PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.grocerymate_sg.id]  # <-- allows access only from EC2 SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grocerymate-rds-sg"
  }
}

# 7 Allocate a static Elastic IP
resource "aws_eip" "grocerymate_eip" {
  domain = "vpc"

  tags = {
    Name = "grocerymate-eip"
  }
}


# 8 Associate Elastic IP with EC2 instance
resource "aws_eip_association" "grocerymate_eip_assoc" {
  instance_id   = aws_instance.grocerymate_ec2.id
  allocation_id = aws_eip.grocerymate_eip.id
}

# 9 Create the PostgreSQL RDS instance
resource "aws_db_instance" "grocerymate_rds" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15.13"
  instance_class       = "db.t3.micro"
  db_name              = "grocerymate_db"
  username             = "postgres"
  password             = "H4rd2Guess123!"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.grocerymate_rds_sg.id]

  tags = {
    Name = "grocerymate-rds"
  }
}
# Outputs

output "ec2_public_ip" {
  value = aws_instance.grocerymate_ec2.public_ip
}
output "rds_endpoint" {
  description = "The endpoint of the RDS PostgreSQL instance"
  value       = aws_db_instance.grocerymate_rds.endpoint
}
