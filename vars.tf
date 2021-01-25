/* Transit VPC variables. Adjust as desired. */

variable "aws_region" {
  default = "us-west-2"
}

/* This AMI map is for the PAN-OS 8.1 Bundle 2 PAYG VM-Series firewall. If you would like
   to use the Bundle 1 PAYG or the BYOL VM-Series, see this link for the destired AMIs:
https://www.paloaltonetworks.com/documentation/global/compatibility-matrix/vm-series-firewalls/aws-cft-amazon-machine-images-ami-list/images-for-pan-os-8-1#id1849DL00W6W
*/

/* If you'd like to specify ami ids for your firewalls, uncomment the var below
and change your FW's AMI to use it instead of the data source below. For example,
you'd use "ami = data.palo_alto_fw_ami[var.aws_region]"

variable "palo_alto_fw_ami" {
  type = map(string)

  default = {
    "us-east-1"      = "ami-bffd3cc2"
    "us-east-2"      = "ami-9ef3c5fb"
    "us-west-1"      = "ami-854551e5"
    "us-west-2"      = "ami-9a29b8e2"
    "sa-east-1"      = "ami-d80653b4"
    "eu-west-1"      = "ami-1fb1ff66"
    "eu-west-2"      = "ami-c4688fa3"
    "eu-central-1"   = "ami-1ebdd571"
    "ca-central-1"   = "ami-57048333"
    "ap-northeast-1" = "ami-75652e13"
    "ap-northeast-2" = "ami-a8bf13c6"
    "ap-southeast-1" = "ami-36bdec4a"
    "ap-southeast-2" = "ami-add013cf"
    "ap-south-1"     = "ami-ee80d981"
  }
}
*/

variable "transit_key_pair" {
  default = "transit-vpc-key"
}

variable "transit_key_pair_public" {
  default = "keys/transit-vpc-key.pub"
}

/* The S3 Bucket name MUST be globally unique. */
variable "bootstrap_bucket" {
  default = "us-west-2-bootstrap-bucket"
}

variable "transit_vpc_cidr_block" {
  default = "10.10.0.0/16"
}

variable "transit_vpc_cidr_prefix" {
  default = "10.10."
}

/* This section specifies what license type and version of the Palo Alto Networks Firewall to use. */

/* Change the default value below to change what version of PANOS to use. */
variable "panos_version" {
  description = "Firewall version to deploy."
  default     = "10.0"
}

/* Change the default value below to change what license type to use. */
variable "license_type" {
  description = "Type of VM-Series to deploy.  Can be one of 'byol', 'bundle-1', 'bundle-2'."
  default     = "bundle-2"
}

variable "license_type_map" {
  type = "map"

  default = {
    byol     = "6njl1pau431dv1qxipg63mvah"
    bundle-1 = "e9yfvyj3uag5uo5j2hjikv74n"
    bundle-2 = "hd44w1chf26uv4p52cdynb2o"
  }
}

/* Create a list of Palo Alto Networks firewall AMI's available for installation */
data "aws_ami" "palo_alto_fw_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.panos_version}*"]
  }

  filter {
    name   = "product-code"
    values = ["${var.license_type_map[var.license_type]}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}
/* Discover and create a list of the Availability Zones for our region. */
data "aws_availability_zones" "available" {
}

/* Create a list of Bastion Host AMI's for Amazon Linux 2 */
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
