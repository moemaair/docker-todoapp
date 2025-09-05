variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-052efd3df9dad4825" # Amazon ubuntu AMI in us-east-1
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "Your AWS EC2 key pair name"
  default     = "my-keypair" # change this to your key pair
}
