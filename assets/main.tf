data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_iam_policy" "web-app-instance-policy" {
  name        = "privileged-instance-policy"
  description = "Provides full access to AWS services and resources."
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
        "*"
      ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "web-app-instance-attachment" {
  policy_arn = aws_iam_policy.web-app-instance-policy.arn
  role       = aws_iam_role.web-app-instance-role.name
}

resource "aws_iam_instance_profile" "web-app-instance-profile" {
  name = "web-app-instance-profile"
  path = "/"
  role = aws_iam_role.web-app-instance-role.name
}

resource "aws_launch_configuration" "mis-configured-launch-config" {
  name             = "ptshggalc1"
  image_id         = data.aws_ami.ubuntu.id
  instance_type    = "t2.micro"
  user_data_base64 = "TFMwdExTMUNSTU9WS1BZUkNGVUxSWTU0NFJUTTk3RUNLVjFRWlA2UjVDNExPNE0yRU9IMjdUVjhGUTUwUzdCM0MyUlhE"

  iam_instance_profile = aws_iam_instance_profile.web-app-instance-profile.name # this iam instance profile has admin permissions

  enable_monitoring = false #cloudWatch Monitoring is disabled

  #the below configuration contributes to IMDSv1
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  security_groups = [aws_security_group.web-app-security-group.id] # this security group has ingress block wide open to internet

  root_block_device {
    volume_type           = "standard"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = false #block is not encrypted
  }

  ebs_block_device {
    device_name = "ebs-device"
    encrypted   = false #block is not encrypted
  }

}
