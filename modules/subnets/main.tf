resource "aws_subnet" "pubsub1" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    name = "pubsub1"
  }

}

resource "aws_subnet" "pubsub2" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    name = "pubsub2"
  }

}