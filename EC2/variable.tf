variable "my_public_key" {
    default= "/tmp/id_rsa.pub"
}
variable "instance_type" {
    default = "t3.large"
}
variable "private-subnet" {
    default = "subnet-7a773b50"
}
variable "ami-id" {
    default = "ami-043a40da97bf4ad72"
}
variable "ports" {
  type    = map(number)
  default = {
    http  = 80
    https = 443
  }
}

variable "ids" {
    type = list
    default =[1,2]
}

variable "vpc_main" {
    default = "vpc-1930977e"
}
variable "aws_subnet_ids" {
    type    = list
    default = ["subnet-d4703cfe", "subnet-d0b38fa6"]
}
