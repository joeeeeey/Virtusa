data "aws_ami" "ubuntu2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for the application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-app-sg"
    },
  )
}

resource "aws_iam_role" "instance_role" {
  name = "${var.project_name}-instance-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-instance-role"
    },
  )
}

# Temporarily commented out while not using Secrets Manager
# resource "aws_iam_role_policy" "secrets_manager_access" {
#   name = "${var.project_name}-secrets-manager-access"
#   role = aws_iam_role.instance_role.id
#
#   policy = jsonencode({
#     Version   = "2012-10-17",
#     Statement = [
#       {
#         Action   = "secretsmanager:GetSecretValue",
#         Effect   = "Allow",
#         Resource = var.db_secret_arn
#       },
#       # Required for SSM Agent to work
#       {
#         Action = [
#           "ssm:UpdateInstanceInformation",
#           "ssmmessages:CreateControlChannel",
#           "ssmmessages:CreateDataChannel",
#           "ssmmessages:OpenControlChannel",
#           "ssmmessages:OpenDataChannel"
#         ],
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy" "ssm_access" {
  name = "${var.project_name}-ssm-access"
  role = aws_iam_role.instance_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      # Required for SSM Agent to work
      {
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.instance_role.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-instance-profile"
    },
  )
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-"
  image_id      = data.aws_ami.ubuntu2204.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host     = var.db_host,
    db_password = var.db_password,
    db_name     = var.db_name,
    region      = "ap-southeast-1" # This should ideally be a variable
  }))

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-launch-template"
    },
  )
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_app_subnet_ids
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_min_size

  target_group_arns = [var.target_group_arn]

  # Mixed instances policy for cost savings
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version           = "$Latest"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 30
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "${var.project_name}-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.asg_target_cpu
  }
} 