variable "ec2-count" {
  description  = "number of ec2 to launch"
  default      = "1"
}

variable "ami" {
  description  = ""
  default      = "ami-0933f1385008d33c4"
}

variable "instance" {
  description   = ""
  default       = {
    "type"      = "t3.micro"
  }
}

variable "key" {
  description  = ""
  default      = {
    "name"     = "terraform"
    "pub"      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdEffxqS3RQQMR0YyQLKWnAQEEc1ThySJWYUhLf7mhXMcgE9dpkAAV6dtNyhrobYHAD2sOh52EG95j6BnjEJXln5Td1053H8se9T2vTxyrnjNmCs0EHyPg5FCIH32YLVZ2iU/iiWaom+1+pf418ouO1HO+lbOi0jwjmUQ+zLxbYxOs1vGCtN3bzzF6tqOPgjOCX7dNr5IySCreshVZbka7IdQFDbHaoqC2HvXJ371asw7W3CbOF9Frn59orCaRneZduKo5LF7EOtx/8QkCRrueNZOAa/RakqlKbb4KfmwAbcAV9JqcWDc63wETv71+oXWLK+rlcJ3jF338hCNLGBkjY54+wMzQWaqdpvRKxOPd2KjcpaCVqZQ2D0L9pUMSbX7UtCBNM5Iczgp2kquVHWgCONrvPC+dKxxPbRVKV05hk3FfZ3qDtTHTL5HDTu1tdGJXYbWhrrcJxmnqQ3cZ92fdxy3CQ6fsr/Kwg6EoKnKwNu6gm9xqQDg809j/gO98+0M= joshua@gbriel-DESKTOP-UV4ETAU"
  }
}

variable "tags" {
  description = ""
  default = {
    "name"       = "tf-frontend-01"
    "app"        = "devops-demo"
    "maintainer" = "joshua"
    "role"       = "frontend"
  }
}

variable rds_name {
  description = ""
  default = "devopsdemo-db"
}

#variable rds_pass {
#  description = "rds password"
#  default = "0000000"
#}

variable "rds_pass" {
  description = "rds password"
  type        = string
  sensitive   = true
}
