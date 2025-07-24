/*  
    .DESCRIPTION
    With Packer installed, it is time to build your first image. In this tutorial, you will build a t2.micro Amazon EC2 AMI. This tutorial will
    provision resources that qualify under the AWS free-tier. If your account doesn't qualify under the  AWS free-tier, we're not responsible
    for any charges that you may incur.

    .Notes
    Packer Shared Credentials File are used in this tutorial to store Amazon credentials on Windows located in %username%/.aws/credentials. If 
    the Amazon builder does not detect credentials inline, or in the environment, the plugin will check this location.
/*

/*
  ----------------------
  - PACKER PLUGIN BLOCK
  - A list of external plugins that the template requires is included in this block.
  ----------------------
*/
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

/*
  ----------------------
  - SOURCE BLOCK
  - Source blocks configure specific builder plugins, which are subsequently invoked by build blocks.
  ----------------------
*/
source "amazon-ebs" "ubuntu" {
  #ami_name      = "learn-packer-linux-aws"
  #ami_name      = "learn-packer-linux-aws-redis"
  #ami_name      = "learn-packer-linux-aws-redis-msg"
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  profile       = "svc_hashicorp_packer"
  region        = "us-east-1"
  #region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

/*
  ----------------------
  - BUILD BLOCK
  - Build blocks define what builders should be started, how to provision them, and if necessary, what to do with their artifacts 
    through post-processing.
  ----------------------
*/
build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }

  provisioner "shell" {
    inline = ["echo This provisioner runs last"]
  }
}

variable "ami_prefix" {
  default = "learn-packer-linux-aws-redis"
  type    = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}