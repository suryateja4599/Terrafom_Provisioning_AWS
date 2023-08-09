variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}

variable "region-worker" {
  type    = string
  default = "us-west-1"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "workers-count" {
  type    = number
  default = 1
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
}


#04/08/2023

variable "webserver-port" {
  type = number
  default = 80
}

07/08/2023

Variable {
  type = number
  default = 
}