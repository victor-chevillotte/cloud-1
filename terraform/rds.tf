resource "aws_db_instance" "wordpress" {
  allocated_storage = 20
  engine            = "mariadb"
  storage_type      = "gp2"

  engine_version          = "10.6.14"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  backup_retention_period = 2 #days
  identifier              = "${var.prefix}-wordpress"
  db_subnet_group_name    = aws_db_subnet_group.my_rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]

}

resource "aws_db_subnet_group" "my_rds" {
  name       = "my_db_subnets"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "rds" {
  name = "my_rds"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-ec2.id]
  }

}


resource "aws_db_instance" "wordpress_replica" {
  engine         = "mariadb"
  storage_type   = "gp2"
  engine_version = "10.6.14"
  identifier     = "${var.prefix}-wordpress-replica"

  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.my_rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  replicate_source_db = aws_db_instance.wordpress.identifier
  skip_final_snapshot = true
}
