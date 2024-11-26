resource "aws_instance" "main" {
  ami                    = data.aws_ami.al2023.id   // 우분투 사용 희망자는 ubuntu_id로 변경
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  private_ip             = "10.0.2.5"
  iam_instance_profile   = "ec2-ssm"
  
  tags = {
    Name = "KTB SSM Public",
    Environment = "SSM"
  }
}
