resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-subnet-group"
    },
  )
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Allow inbound traffic from application layer"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-sg"
    },
  )
}

# Temporarily commented out to resolve API timeout issues
# resource "aws_secretsmanager_secret" "db_creds" {
#   name = "${var.project_name}-rds-creds"
#   recovery_window_in_days = 0 # Not recommended for prod
# }

resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp3"
  max_allocated_storage  = 100 # for storage autoscaling

  db_name                = replace("${var.project_name}db", "-", "")
  username               = "admin"
  password               = random_password.master.result
  
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db.id]
  
  multi_az               = var.db_multi_az
  skip_final_snapshot    = true
  
  backup_retention_period = 7
  performance_insights_enabled = var.db_instance_class == "db.t3.micro" ? false : true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-instance"
    },
  )
}

# Temporarily commented out to resolve API timeout issues
# resource "aws_secretsmanager_secret_version" "db_creds" {
#   secret_id     = aws_secretsmanager_secret.db_creds.id
#   secret_string = jsonencode({
#     username = "admin"
#     password = random_password.master.result
#     engine   = "mysql"
#     host     = aws_db_instance.main.address
#     port     = aws_db_instance.main.port
#     dbname   = aws_db_instance.main.db_name
#   })
#   
#   depends_on = [aws_db_instance.main]
# } 