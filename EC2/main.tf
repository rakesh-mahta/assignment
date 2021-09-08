provider "aws" {
    region= "us-east-1"
}

# Security Group Creation 
resource "aws_security_group" "web_servers_sg"{
    name = "prod-web-servers-sg"
    vpc_id = var.vpc_main
}
# Ingress Security Port 80 
resource "aws_security_group_rule" "http_inbound_access" {
    from_port = 80
    protocol = "tcp"
    security_group_id = "{aws_security_group.web-servers-sg.id}"
    to_port = 80 
    type = "ingress"
    cidr_blocks = ["0.0.0.0/0"]
}
 
resource "aws_security_group_rule" "https_inbound_access" {
    from_port = 443
    protocol = "tcp"
    security_group_id = "{aws_security_group.web-servers-sg.id}"
    to_port = 443 
    type = "ingress"
    cidr_blocks = ["0.0.0.0/0"]
}
# All Outbound Access 
resource "aws_security_group_rule" "all_outbound_access" {
    from_port = 0
    protocol = "-1"
    security_group_id = "{aws_security_group.web-servers-sg.id}"
    to_port = 0 
    type = "egress"
    cidr_blocks = ["0.0.0.0/0"]
}
# key-pair 
resource "aws_key_pair" "mytest-key" {
    key_name = "prod-web-server-key"
    public_key = "{file(var.my_public_key)}"
}

#EC2 Instance Creation 
resource "aws_instance" "prod_web_server" {
    count =2 
    ami = var.ami-id
    instance_type= var.instance_type
    key_name = aws_key_pair.mytest-key.id
    vpc_security_group_ids = ["${aws_security_group.web_servers_sg.id}"]
    subnet_id = var.private-subnet
    #user_data = "${data.template_file.init.rendered}"

    tags = {
        Name = "prod-web-server-${count.index +1}"
    }

}

# User data should be added to EC2 instance in order to pass the lb healthcheck 

#data "template_file" "init" {
#  template = "$file("${path.module}/userdata.tpl)"
#  }

############################## NLB ###########################


resource "aws_lb" "prod_web_server_nlb" {
  name               = "network-load-balancer"
  load_balancer_type = "network"
  subnets            = var.aws_subnet_ids

  enable_cross_zone_load_balancing = true
}

#Listener 

resource "aws_lb_listener" "NLB" {
  for_each = var.ports

  load_balancer_arn = aws_lb.prod_web_server_nlb.arn

  protocol          = "TCP"
  port              = each.value

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-tg[each.key].arn
  }
}


resource "aws_lb_target_group" "nlb-tg" {
  for_each = var.ports

  port        = each.value
  protocol    = "TCP"
  vpc_id      = var.vpc_main

  #stickiness = []

  depends_on = [
    aws_lb.prod_web_server_nlb
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "prod-web-server2-tg-http" {
    target_group_arn = aws_lb_target_group.nlb-tg["http"].arn
    target_id = "$element(aws_instance.prod_web_server.*.id, 1]})"
    depends_on = [
    aws_instance.prod_web_server
  ] 
}

resource "aws_lb_target_group_attachment" "prod-web-server2-tg-https" {
    target_group_arn = aws_lb_target_group.nlb-tg["https"].arn
    target_id = "$element(aws_instance.prod_web_server.*.id, 2]})"
    depends_on = [
    aws_instance.prod_web_server
  ]
  
}

