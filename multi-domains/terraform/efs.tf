# EFS creation
resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = "${var.prefix}-efs"
  tags = {
    Name = "${var.prefix}-EFS"
  }
}

# EFS Mount points in each subnet
resource "aws_efs_mount_target" "efs_mount" {
  for_each        = toset(data.aws_subnets.default.ids)
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.dev-ec2.id]
}
