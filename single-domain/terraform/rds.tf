resource "aws_db_instance" "cloud1" {
  allocated_storage = 20
  engine            = "mariadb"
  storage_type      = "gp2"

  engine_version          = "10.6.14"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  backup_retention_period = 0 #days
  identifier              = "${var.prefix}-${var.db_name}"
  db_subnet_group_name    = aws_db_subnet_group.cloud1.name
  vpc_security_group_ids  = [aws_security_group.cloud1.id]

}

resource "aws_db_subnet_group" "cloud1" {
  name       = "${var.prefix}-${var.db_name}"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "cloud1" {
  name = "${var.prefix}-rds-${var.db_name}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-ec2.id]
  }

}