module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "app-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


module "webapp_secg" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"

  name        = "webapp-sg"
  description = "Security group for web app with HTTP ports open"
  vpc_id      = module.vpc.vpc_id

  #   ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "lb_secg" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"

  name        = "lb-sg"
  description = "Security group for load balancer with HTTP ports open"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "app" {
  name               = "main-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [module.lb_secg.this_security_group_id]
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    forward {
        target_group {
          arn    = aws_lb_target_group.blue.arn
          weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
        }

        target_group {
          arn    = aws_lb_target_group.green.arn
          weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
        }

        stickiness {
          enabled  = false
          duration = 1
        }
      }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

output "lb_dns_name" {
  value = aws_lb.app.dns_name
}