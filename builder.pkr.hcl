packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "aws-eks-node-default"
}

/*variable "secret_key" {
  type      = string
  default   = "${env("AWS_SECRET_ACCESS_KEY")}"
  sensitive = true
}
variable "access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}
variable "session_token" {
  type    = string
  default = "${env("AWS_SESSION_TOKEN")}"
}
*/
variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "ami_filter_name" {
  type    = string
  default = "amazon-eks-*"
}

variable "source_ami_owners" {
  type      = string
  default   = "602401143452"
  sensitive = true
}

variable "security_group_id" {
  type    = string
  default = "<Security Group ID"
}

variable "source_ami_id" {
  type    = string
  default = "ami-09a3ebc18faf67c69"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "cis_hardened_image" {
  source_ami             = "${var.source_ami_id}"
  region                 = "${var.region}"
  security_group_id      = "${var.security_group_id}"
  ami_name               = "${var.ami_prefix}-${local.timestamp}"
  skip_region_validation = "true"
  source_ami_filter {
    filters = {
      name                = "${var.ami_filter_name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["${var.source_ami_owners}"]
  }
  instance_type = "${var.instance_type}"
  ssh_username  = "ec2-user"
  tags          = { "Release" : "1.0", "Name" : "${var.ami_prefix}-${local.timestamp}", "creator" : "puneet", "builder" : "packer" }

}

build {
  name = "cis_harderned_node"
  sources = [
    "source.amazon-ebs.cis_hardened_image"
  ]

  provisioner "shell" {
    script = "scripts/inspector.sh"

  }
  provisioner "shell" {
    script          = "scripts/cis-rest.sh"
    execute_command = "sudo -S env {{ .Vars }} {{ .Path }}"
    inline_shebang  = "/bin/bash -ex"
  }


  provisioner "ansible" {
    playbook_file = "AMAZON2-CIS/site.yml"
    user          = "ec2-user"
    ansible_ssh_extra_args = [
      "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
    ]
    extra_arguments = ["--extra-vars", "ansible_python_interpreter=/usr/bin/python"]
  }

  post-processor "manifest" {
      output = "manifest.json"
      strip_path = true
      // AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ":" -f2)
  }
}
