resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks_vpc"
  }
}

module "subnets" {
  source = "./modules/subnets"
  vpc_id = aws_vpc.eks_vpc.id
}

locals {
  pub_subnet_ids = [module.subnets.pub_id]
  priv_subnet_ids = [module.subnets.priv1_id, module.subnets.priv2_id]
}

resource "aws_eks_cluster" "nws" {
  name     = "nws-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [module.subnets.priv1_id, module.subnets.priv2_id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "nws-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}
 
resource "aws_iam_role_policy_attachment" "eks_vpc_cni_ipv4_policy" {
  count      = var.vpc_cni_enable_ipv4 ? 1 : 0
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_cni_ipv6_policy" {
  count      = var.vpc_cni_enable_ipv6 ? 1 : 0
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_IPv6_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks_igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nws" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.subnets.pub_id
  depends_on    = [aws_internet_gateway.eks_igw]
}

resource "aws_route_table" "nws" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nws.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = module.subnets.pub_id
  route_table_id = aws_route_table.nws.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks_public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = module.subnets.pub_id
  route_table_id = aws_route_table.public.id
}

resource "aws_eks_node_group" "nws" {
  cluster_name    = aws_eks_cluster.nws.name
  node_group_name = "nws-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [module.subnets.priv1_id, module.subnets.priv2_id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.micro"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read,
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "nws-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}
