data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  filter {
    name   = "region-name"
    values = [data.aws_region.current.region]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
