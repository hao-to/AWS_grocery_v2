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
  public_key = file("public_key.pub")
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
    cidr_blocks = ["93.128.39.117/32"]

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
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.grocerymate_rds_sg.id]

  tags = {
    Name = "grocerymate-rds"
  }
}
