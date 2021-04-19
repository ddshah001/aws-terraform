## EC2 INSTANCES
resource "aws_instance" "app" {
  count                         = 3
  ami                           = "ami-0742b4e673072066f"
  instance_type                 = "t2.micro"
  key_name                      = "Tef"
  vpc_security_group_ids        = [aws_security_group.app_sg.id]
  subnet_id                     = aws_subnet.app_subnet.id
  associate_public_ip_address   = "true"
  tags = {  
    Name = "app_${count.index}"
  }
}

## NLB
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.app_subnet.*.id
  tags = {
    Environment = "dev"
  }
}

## LB Target Group
resource "aws_lb_target_group" "app_tgp" {
  name     = "app-tgp"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.app_vpc.id
}

## LB Targets Registration
resource "aws_lb_target_group_attachment" "app_tgpa" {
  count            = length(aws_instance.app)
  target_group_arn = aws_lb_target_group.app_tgp.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}

## LB Listener
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tgp.arn
  }
}