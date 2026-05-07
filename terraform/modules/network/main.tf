resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-gateway-endpoint"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "vpc_endpoints" {
  count = var.create_cloudwatch_logs_endpoint ? 1 : 0

  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "Security group for interface VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow HTTPS from inside VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow outbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count = var.create_cloudwatch_logs_endpoint ? 1 : 0

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-logs-interface-endpoint"
    Project     = var.project_name
    Environment = var.environment
  }
}