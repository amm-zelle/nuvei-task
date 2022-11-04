#################
# Input Variables  
#################

# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"
}

# AWS EC2 Instance Type - Map
variable "instance_type_map" {
  description = "EC2 Instance Type"
  type = map(string)
  default = {
    "dev" = "t2.micro"
    "qa" = "t3.large"
    "prod" = "m5.large"
  }
}

variable "key_pair" {
	description = "The ec2 key pair"
	type = string
	default = "C27"
}

variable "ec2_number" {
 description = "Number of EC2 Instances" 
 type = number 
 default =  2
}

variable "ingressrules" {
  description = "VPC Ingress Rule for Dynamic Ingress" 
  type = list(number)
  default = [80,443]
}
/*
variable "egressrules" {
  description = "VPC egress Rule for Dynamic Engress" 
  type = list(number)
  default = [80,443,22,25,3306,53,8080]
}
*/
variable "ingress_cidr_block" {
  type = map(string)
  description = "cidr blocks for access in security groups"
  default = {
    "public_cidr" = "0.0.0.0/0"
    "private_cidr" = "10.0.0.0/16"
  }
}

variable "prod_dns_zone" {
	description = "Name of route53 dns hosted zone"
	type = string
	default = "fammy.click."
}

variable "prod_domain_name" {
	description = "Registered domain name for ACM to issue SSL certificate"
	type = string
	default = "fammy.click"
}

variable "alias_record_name" {
	description = "The name of the A record"
	type = string
	default = "www.fammy.click"
}

variable "cname_record_name" {
	description = "The name of the cname record"
	type = string
	default = "pay"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}
# Business Division
variable "business_division" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "Finance"
}