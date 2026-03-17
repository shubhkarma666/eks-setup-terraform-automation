# AWS provider config (region = Mumbai)
provider "aws" {
  region = "ap-south-1"
}


# Create VPC (main network)
resource "aws_vpc" "shubham_vpc" {
  cidr_block = "10.0.0.0/16"   # private IP range

  tags = {
    Name = "shubham-vpc"
  }
}


# Create 2 public subnets
resource "aws_subnet" "shubham_subnet" {
  count = 2   # create 2 subnets

  vpc_id = aws_vpc.shubham_vpc.id   # attach to VPC

  cidr_block = cidrsubnet(aws_vpc.shubham_vpc.cidr_block, 8, count.index)  
  # split VPC CIDR into smaller subnets

  availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)  
  # place subnet in AZ

  map_public_ip_on_launch = true   # auto assign public IP

  tags = {
    Name = "shubham-subnet-${count.index}"
  }
}


# Internet Gateway (for internet access)
resource "aws_internet_gateway" "shubham_igw" {
  vpc_id = aws_vpc.shubham_vpc.id

  tags = {
    Name = "shubham-igw"
  }
}


# Route table (defines traffic rules)
resource "aws_route_table" "shubham_route_table" {
  vpc_id = aws_vpc.shubham_vpc.id

  route {
    cidr_block = "0.0.0.0/0"   # allow all traffic
    gateway_id = aws_internet_gateway.shubham_igw.id   # send via IGW
  }

  tags = {
    Name = "shubham-route-table"
  }
}


# Attach route table to subnets
resource "aws_route_table_association" "a" {
  count = 2

  subnet_id = aws_subnet.shubham_subnet[count.index].id   # each subnet
  route_table_id = aws_route_table.shubham_route_table.id   # same RT
}


# Security group for EKS cluster
resource "aws_security_group" "shubham_cluster_sg" {
  vpc_id = aws_vpc.shubham_vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"   # all protocols
    cidr_blocks = ["0.0.0.0/0"]   # allow outbound anywhere
  }

  tags = {
    Name = "shubham-cluster-sg"
  }
}


# Security group for nodes
resource "aws_security_group" "shubham_node_sg" {
  vpc_id = aws_vpc.shubham_vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"   # allow all inbound
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"   # allow all outbound
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shubham-node-sg"
  }
}


# EKS Cluster (control plane)
resource "aws_eks_cluster" "shubham" {
  name = "shubham-cluster"

  role_arn = aws_iam_role.shubham_cluster_role.arn   # IAM role for EKS

  vpc_config {
    subnet_ids = aws_subnet.shubham_subnet[*].id   # use both subnets
    security_group_ids = [aws_security_group.shubham_cluster_sg.id]
  }
}


# Node group (worker nodes)
resource "aws_eks_node_group" "shubham" {
  cluster_name = aws_eks_cluster.shubham.name

  node_group_name = "shubham-node-group"

  node_role_arn = aws_iam_role.shubham_node_group_role.arn   # node IAM role

  subnet_ids = aws_subnet.shubham_subnet[*].id   # launch nodes in subnets

  scaling_config {
    desired_size = 2   # number of nodes
    max_size = 3
    min_size = 1
  }

  instance_types = ["t3.small"]   # EC2 type for WorkerNODE

  remote_access {
    ec2_ssh_key = var.ssh_key_name   # SSH key

    source_security_group_ids = [aws_security_group.shubham_node_sg.id]
    # allow SSH via this SG
  }
}


# IAM role for EKS cluster
resource "aws_iam_role" "shubham_cluster_role" {
  name = "shubham-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# Attach policy to cluster role
resource "aws_iam_role_policy_attachment" "shubham_cluster_role_policy" {
  role = aws_iam_role.shubham_cluster_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# IAM role for worker nodes
resource "aws_iam_role" "shubham_node_group_role" {
  name = "shubham-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# Attach worker node policies
resource "aws_iam_role_policy_attachment" "shubham_node_group_role_policy" {
  role = aws_iam_role.shubham_node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "shubham_node_group_cni_policy" {
  role = aws_iam_role.shubham_node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "shubham_node_group_registry_policy" {
  role = aws_iam_role.shubham_node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}