data "aws_ssm_parameter" "username" {
 name = "roboshop.${env}.mysql.username"
}

data "aws_ssm_parameter" "password" {
  name = "roboshop.${env}.mysql.password"
}