resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags =  merge({
    Name = "${var.component}-${var.env}"
  }, var.tags)
}

resource "aws_security_group" "sg-1" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.sg_subnet_cidr

  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}


resource "aws_rds_cluster" "rds" {
  cluster_identifier      = "${var.component}-${var.env}"
  engine                  = var.engine
  engine_version          = var.engine_Version
  database_name = var.db_name
  master_username         = data.aws_ssm_parameter.username.value
  master_password         = data.aws_ssm_parameter.password.value
  storage_encrypted  =  true
  kms_key_id = var.kms_key_arn
  db_subnet_group_name = aws_db_subnet_group.main.id
  skip_final_snapshot = var.skip_final_snapshot

  vpc_security_group_ids = [aws_security_group.sg-1.id]

}

resource "aws_rds_cluster_instance" "rds_instances" {
  count              = var.instance_count
  identifier         = "${var.component}-${var.env}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.rds.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.rds.engine
  engine_version     = aws_rds_cluster.rds.engine_version


}


