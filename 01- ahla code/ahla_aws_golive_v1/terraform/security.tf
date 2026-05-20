resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "ALB SG"
  vpc_id      = aws_vpc.this.id
  ingress { from_port = 80  to_port = 80  protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 443 to_port = 443 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0   to_port = 0   protocol = "-1"  cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_security_group" "nlb_turn" {
  name        = "${var.project}-nlb-turn-sg"
  description = "NLB TURN SG (ref for reference, NLB is L4)"
  vpc_id      = aws_vpc.this.id
  # NLB itself ignores SG but targets will use their SGs
}

resource "aws_security_group" "tasks" {
  name        = "${var.project}-tasks-sg"
  vpc_id      = aws_vpc.this.id
  ingress { from_port = 0 to_port = 65535 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 0 to_port = 65535 protocol = "udp" cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0 to_port = 0     protocol = "-1"  cidr_blocks = ["0.0.0.0/0"] }
}
