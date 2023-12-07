# Création du système de fichiers EFS
resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = "wordpress-efs"
  tags = {
    Name = "WordpressEFS"
  }
}

# Points de montage EFS sur les sous-réseaux pour les instances EC2
resource "aws_efs_mount_target" "efs_mount" {
  for_each          = data.aws_subnets.default.ids
  file_system_id    = aws_efs_file_system.wordpress_efs.id
  subnet_id         = each.value
  security_groups   = [aws_security_group.dev-ec2.id]
}

