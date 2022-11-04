####################
# VPC Security Group
####################

resource "aws_default_security_group" "web-traffic" {

    vpc_id      = module.vpc.vpc_id

    dynamic "ingress" {
        iterator = port
        for_each = var.ingressrules
        content {
        from_port = port.value
        to_port = port.value
        protocol = "TCP"
        #cidr_blocks = ["0.0.0.0/0"]
        cidr_blocks  = [var.ingress_cidr_block["public_cidr"]] # For Map
        ipv6_cidr_blocks = ["::/0"]
        #cidr_blocks = [module.vpc.vpc_cidr_block]
        #ipv6_cidr_blocks = [module.vpc.vpc_ipv6_cidr_block] 
        description = "Allow Web Traffic From Anywhere"
        }
    }


    ingress {
    description = "Allow SSH Traffic From Private Network"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    #cidr_blocks = [module.vpc.vpc_cidr_block]
    cidr_blocks  = [var.ingress_cidr_block["private_cidr"]] # For Map
    ipv6_cidr_blocks = [module.vpc.vpc_ipv6_cidr_block]
  }

  egress {
    description = "Allow all ip and ports outbound"    
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]


  /*
     dynamic "egress" {
        iterator = port
        for_each = var.egressrules
        content {
        from_port = port.value
        to_port = port.value
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        }
    }
  */ 
  }
    tags = {
    Name = "web-traffic"
  }
}

