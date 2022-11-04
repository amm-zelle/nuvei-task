###################
# Generic Variables
###################

aws_region = "us-east-1"
instance_type_map = {"dev" = "t2.micro", "qa" = "t3.micro", "prod" = "t2.micro" }
key_pair = "C27"
ec2_number = 2
ingressrules = [80,443]
ingress_cidr_block = { "public_cidr" = "0.0.0.0/0","private_cidr" = "10.0.0.0/16" }
prod_dns_zone = "fammy.click."
prod_domain_name = "fammy.click"
alias_record_name = "www.fammy.click"
cname_record_name = "pay"
environment = "prod"
business_division = "HR1"