#obtengo el ami para las instancias back
data "aws_ami" "back-latest-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
#obtengo el ami para las instancias front. Es el mismo ami, pero así se puede modificar rápidamente.
data "aws_ami" "front-latest-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}


