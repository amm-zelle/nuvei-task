########################
# EC2 Instance Resources
########################

resource "aws_instance" "web_ec2" {
  ami = data.aws_ami.redhat8.id # us-east-1
  instance_type = var.instance_type_map["prod"]  # For Map
  user_data     = file("${path.module}/app1-install.sh")
  #vpc_security_group_ids = [ aws_default_security_group.web-trafic.id]
  key_name = var.key_pair
  count = "${var.ec2_number}"
  subnet_id = "${element(module.vpc.public_subnets, count.index)}"
  tags = {
      "Name" = "web-${count.index + 1}-${local.name}"
      "Environment" = var.environment
  }
}


resource "aws_instance" "app_ec2" {
  ami = data.aws_ami.redhat8.id # us-east-1
  instance_type = var.instance_type_map["prod"]  # For Map
  #user_data     = file("${path.module}/app1-install.sh")
  #vpc_security_group_ids = [ aws_default_security_group.web-trafic.id]
  key_name = var.key_pair
  count = "${var.ec2_number}"
  subnet_id = "${element(module.vpc.private_subnets, count.index)}"
  tags = {
      "Name" = "app-${count.index + 1}-${local.name}"
      "Environment" = var.environment
  }
}


/*
# Drawbacks of using count in this example
- Resource Instances in this case were identified using index numbers
instead of string values like actual subnet_id
- If an element was removed from the middle of the list,
every instance after that element would see its subnet_id value
change, resulting in more remote object changes than intended.
- Even the subnet_ids should be pre-defined or we need to get them again
using for_each or for using various datasources
- Using for_each gives the same flexibility without the extra churn.
*/