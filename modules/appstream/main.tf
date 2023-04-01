resource "aws_appstream_fleet" "this" {

  compute_capacity {
    desired_instances = var.desired_instance_num
  }

  name                               = var.fleet_name
  description                        = var.fleet_description
  display_name                       = var.fleet_display_name
  enable_default_internet_access     = false
  fleet_type                         = "ON_DEMAND"
  image_name                         = var.image_name
  instance_type                      = var.instance_type
  iam_role_arn                       = aws_iam_instance_profile.as2_instance.arn
  idle_disconnect_timeout_in_seconds = 1800 # 30 mins
  disconnect_timeout_in_seconds      = 60
  max_user_duration_in_seconds       = 7200 # 2 hours

  stream_view = "DESKTOP"

  vpc_config {
    subnet_ids         = var.fleet_subnet_ids
    security_group_ids = [aws_security_group.appstream.id]
  }
}

resource "aws_appstream_stack" "this" {
  name         = var.stack_name
  description  = var.stack_description
  display_name = var.stack_display_name
  #feedback_url = "http://your-domain/feedback"
  #redirect_url = "http://your-domain/redirect"

  storage_connectors {
    connector_type = "HOMEFOLDERS"
  }

  user_settings {
    action     = "CLIPBOARD_COPY_FROM_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_TO_LOCAL_DEVICE"
    permission = "DISABLED"
  }
  user_settings {
    action     = "FILE_UPLOAD"
    permission = "ENABLED"
  }
  user_settings {
    action     = "FILE_DOWNLOAD"
    permission = "DISABLED"
  }
  user_settings {
    action     = "DOMAIN_PASSWORD_SIGNIN"
    permission = "ENABLED"
  }
  user_settings {
    action     = "DOMAIN_SMART_CARD_SIGNIN"
    permission = "DISABLED"
  }
  user_settings {
    action     = "PRINTING_TO_LOCAL_DEVICE"
    permission = "DISABLED"
  }

}

# Associates fleet to stack
resource "aws_appstream_fleet_stack_association" "this" {
  fleet_name = aws_appstream_fleet.this.name
  stack_name = aws_appstream_stack.this.name
}