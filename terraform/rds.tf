resource "aws_db_instance" "default" {
  allocated_storage                   = 5
  engine                              = "mysql"
  engine_version                      = "5.7"
  instance_class                      = "db.t3.micro"
  db_name                             = var.db_name
  username                            = var.db_username
  password                            = var.db_password
  parameter_group_name                = "default.mysql5.7"
  skip_final_snapshot                 = true
  identifier                          = "my-rds"
  iam_database_authentication_enabled = true
  db_subnet_group_name                = aws_db_subnet_group.my_rds.name
  vpc_security_group_ids              = [aws_security_group.rds.id]

}

resource "aws_db_subnet_group" "my_rds" {
  name       = "my_db_subnets"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "rds" {
  name = "my_rds"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-ec2.id]
  }

}
