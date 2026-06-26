resource "aws_vpc" "vpc-3-tier" {
  cidr_block = "10.0.0.0/16"
  #   ins
  tags = {
    Name = "three-tier-vpc"
  }
}
