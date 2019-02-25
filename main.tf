provider "aws" {
/* Credentials are stored/parsed in ~/.aws/credentials, not here
  access_key = "ACCESS_KEY_HERE"
  secret_key = "SECRET_KEY_HERE" */
  region     = "${var.region}"
}

resource "aws_vpc" "k8s" {
  cidr_block                       = "${var.k8s_vpc_CIDR}"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = "false"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  tags {
    Name        = "k8s"
    Terraform   = "true"
  }
}


resource "aws_subnet" "private-01" {
  count                   = "${var.enable_priv_subs ? 1 : 0}"
  vpc_id                  = "${aws_vpc.k8s.id}"
  availability_zone       = "${var.private_subnet-01_AZ}"
  cidr_block              = "${var.private_subnet-01_CIDR}"
  tags {
    Name        = "private-01"
    Terraform   = "true"
  }
}

resource "aws_subnet" "private-02" {
  count                   = "${var.enable_priv_subs ? 1 : 0}"
  vpc_id                  = "${aws_vpc.k8s.id}"
  availability_zone       = "${var.private_subnet-02_AZ}"
  cidr_block              = "${var.private_subnet-02_CIDR}"
  tags {
    Name        = "private-02"
    Terraform   = "true"
  }
}

resource "aws_subnet" "public-01" {
  vpc_id                  = "${aws_vpc.k8s.id}"
  availability_zone       = "${var.public_subnet-01_AZ}"
  cidr_block              = "${var.public_subnet-01_CIDR}"
  tags {
    Name        = "public-01"
    Terraform   = "true"
  }
}


resource "aws_subnet" "public-02" {
  vpc_id                  = "${aws_vpc.k8s.id}"
  availability_zone       = "${var.public_subnet-02_AZ}"
  cidr_block              = "${var.public_subnet-02_CIDR}"
  tags {
    Name        = "public-02"
    Terraform   = "true"
  }
}


resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
  timeouts {
    create      = "5m"
  }
}


resource "aws_route_table" "public" {
 vpc_id                  = "${aws_vpc.k8s.id}"
 tags {
    Terraform   = "true"
  }
}

resource "aws_internet_gateway" "this" {
 vpc_id                  = "${aws_vpc.k8s.id}"
}



resource "aws_route_table_association" "public-01" {
  subnet_id              = "${aws_subnet.public-01.id}"
  route_table_id         = "${aws_route_table.public.id}"
}


resource "aws_route_table_association" "public-02" {
  subnet_id              = "${aws_subnet.public-02.id}"
  route_table_id         = "${aws_route_table.public.id}"
}


resource "aws_eip" "nat" {
  count                  = "${var.enable_priv_subs ? 1 : 0}"
  vpc                    = true
}

resource "aws_nat_gateway" "this" {
  count                  = "${var.enable_priv_subs ? 1 : 0}"
  allocation_id          = "${aws_eip.nat.id}"
  subnet_id              = "${aws_subnet.public-01.id}"
  depends_on             = ["aws_internet_gateway.this"]
}

resource "aws_route_table" "private" {
  count                  = "${var.enable_priv_subs ? 1 : 0}"
  vpc_id                 = "${aws_vpc.k8s.id}"
  tags {
    Terraform   = "true"
  }
}

resource "aws_route" "nat_gateway" {
  count                  = "${var.enable_priv_subs ? 1 : 0}"
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_nat_gateway.this.id}"
  timeouts {
    create = "5m"
  }
}


resource "aws_route_table_association" "private-01" {
  count                  = "${var.enable_priv_subs ? 1 : 0}"
  subnet_id              = "${aws_subnet.private-01.id}"
  route_table_id         = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-02" {
  count                  = "${var.enable_priv_subs ? 1 : 0}"
  subnet_id              = "${aws_subnet.private-02.id}"
  route_table_id         = "${aws_route_table.private.id}"
}


module "eks" {
  source                = "../modules/terraform-aws-eks"
  cluster_name          = "test-eks-cluster"
  subnets               = ["${aws_subnet.public-01.id}", "${aws_subnet.public-02.id}"]
  tags                  = {Environment = "test"}
  vpc_id                = "${aws_vpc.k8s.id}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = "this"
  count                 = "${var.enable_es ? 1 : 0}"
  ebs_options{
    ebs_enabled         = "true"
    volume_type         = "${var.es_ebs_volume_type}"
    volume_size         = "${var.es_ebs_volume_size}"
  }

  cluster_config {
    instance_type = "${var.es_ebs_instance_type}"
  }
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource":  "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/this/*"

    }
  ]
}
POLICY

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = {
    Domain = "this"
  }
}
