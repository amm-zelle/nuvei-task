##########################################
# Data sources to get EC2 Instance details
##########################################
data "aws_ami" "redhat8" {
  most_recent = true
  owners = [ "309956199498" ]

  filter {
    name = "name"
    values = [ "RHEL-8.4.0_HVM-*-GP2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}
