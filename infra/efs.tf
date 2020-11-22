resource "aws_efs_file_system" "notejam" {
  creation_token = "${var.APP}-efs"
  encrypted      = true
  tags = {
    Name = "${var.APP}-${var.ENV}-efs"
    App  = var.APP
  }
}

resource "aws_efs_access_point" "notejam" {
  file_system_id = aws_efs_file_system.notejam.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
  tags = {
    Name = "${var.APP}-${var.ENV}-efs-access-point"
    App  = var.APP
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.ecs-main.id
}

resource "aws_efs_mount_target" "notejam" {
  // count           = length(data.aws_subnet_ids.public.ids)
  count           = 3
  file_system_id  = aws_efs_file_system.notejam.id
  subnet_id       = tolist(data.aws_subnet_ids.public.ids)[count.index]
  security_groups = [aws_vpc.ecs-main.default_security_group_id]
  depends_on      = [aws_subnet.main-public-1, aws_subnet.main-public-2, aws_subnet.main-public-3]
}

