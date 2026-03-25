terraform {
  backend "s3" {
    bucket = "devpos-demo-1235"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "terraform-lock"
  }
}
