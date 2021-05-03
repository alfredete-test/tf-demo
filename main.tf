provider "aws" {
  region  = var.region
}

resource "aws_key_pair" "from_local" {
  key_name   = "from_local"
  public_key = file("public.pub")


}
