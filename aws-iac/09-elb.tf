
##################
# ACM certificate
##################
resource "aws_route53_delegation_set" "prod" {
  reference_name = "DynDNS"

}

resource "aws_route53_zone" "fammy" {
  name          = var.prod_dns_zone
  #name          = "fammy.click."
  delegation_set_id = aws_route53_delegation_set.prod.id
  force_destroy = true
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  zone_id = aws_route53_zone.fammy.zone_id
  domain_name  = var.prod_domain_name
  #domain_name   = "fammy.click"
  subject_alternative_names = ["*.${var.prod_domain_name}"]
  #subject_alternative_names = ["*.fammy.click"]

  wait_for_validation = true

  tags = {
    Environment = "prod"
  }
}

#################################
# ELB listening on Ports 80 & 443
#################################

resource "aws_elb" "prod-elb" {
  name               = "prod-elb"
  subnets      = module.vpc.public_subnets
  security_groups = [aws_default_security_group.web-traffic.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = module.acm.acm_certificate_arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    #target              = "HTTPS:443/index.html"
    target              = "HTTP:80/index.html"
    interval            = 30
  }
  instances = aws_instance.web_ec2.*.id
  #instances                   = [aws_instance.web_ec2[0].id, aws_instance.web_ec2[1].id]
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "prod-elb"
  }
}

# ELB Output

output "elb-dns-name" {
  value = aws_elb.prod-elb.dns_name
}

#####################
# SSL security policy
######################

resource "aws_lb_ssl_negotiation_policy" "prod-elb-ssl-policy" {
  name          = "prod-elb-ssl-policy"
  load_balancer = "${aws_elb.prod-elb.id}"
  lb_port       = 443

  attribute {
    name  = "Reference-Security-Policy"
    value = "ELBSecurityPolicy-2016-08"
  }

}


#################################################
# Update Domain NS to Point to the Hosted Zone NS
#################################################
resource "aws_route53domains_registered_domain" "fammy" {
    domain_name = aws_route53_zone.fammy.name
  
    dynamic "name_server" {
      for_each = toset(aws_route53_zone.fammy.name_servers)
      content {
        name = name_server.value
      }
    }

    lifecycle {
      prevent_destroy = false
      create_before_destroy = false
  }
}

###############################
# Hosted Zone NS Record For ELB
###############################
# NS Record is automatically created by the AWS Route53 whenever a hosted zone is created 
# and is not dirrectly controlled by Terraform
# Uncomment and allow overwrite to bring the NS Record under the control of Terraform
/*
resource "aws_route53_record" "fammy" {
  allow_overwrite = true
  name            = "fammy.click"
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.fammy.zone_id

  records = [
    aws_route53_zone.fammy.name_servers[0],
    aws_route53_zone.fammy.name_servers[1],
    aws_route53_zone.fammy.name_servers[2],
    aws_route53_zone.fammy.name_servers[3],
  ]
}
*/

##############################
# Hosted Zone A Record For ELB
##############################
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.fammy.zone_id
  name  =  var.alias_record_name
  #name    = "www.fammy.click"
  type    = "A"

  alias {
    name                   = aws_elb.prod-elb.dns_name
    zone_id                = aws_elb.prod-elb.zone_id
    evaluate_target_health = true
  }
}
##################################
# Hosted Zone CNAME Record For ELB
##################################

resource "aws_route53_record" "record_pay" {
  type    = "CNAME"
  name    = var.cname_record_name
  #name    = "pay"
  ttl     = "86400"
  zone_id = aws_route53_zone.fammy.zone_id
  #zone_id = "${aws_route53_zone.fammy.zone_id}"
  records = ["${aws_elb.prod-elb.dns_name}"]
}
