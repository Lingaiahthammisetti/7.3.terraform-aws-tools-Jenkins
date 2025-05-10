module "jenkins_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "tf-jenkins-master"

  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-06b1b57b365846051"] #replace your SG
   ami                   = data.aws_ami.ami_info.id
  #ami                    = "ami-041e2ea9402c46c32"
  #user_data              = file("install_jenkins_master.sh")
  user_data               = file("${path.module}/install_jenkins_master.sh")

  tags = {
    Name   = "Jenkins-Master"
  }
}
module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "tf-jenkins-agent"

  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-06b1b57b365846051"] #replace your SG
  ami                   = data.aws_ami.ami_info.id
  #ami                    = "ami-041e2ea9402c46c32"
  #user_data              = file("install_jenkins_agent.sh")
  user_data               = file("${path.module}/install_jenkins_agent.sh")

  tags = {
    Name   = "Jenkins-Agent"
  }
}


resource "aws_key_pair" "tools" {
    key_name = "tools-key"
    #you can paste the public key directly like this
    #public_key = file("~/.ssh/openssh.pub")
    # ~ means windows home directory
    public_key = "${file("~/.ssh/tools.pub")}"

}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "nexus"

  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-06b1b57b365846051"] #replace your SG
  ami                   = data.aws_ami.nexus_ami_info.id
  key_name = aws_key_pair.tools.key_name
   
    root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 50
    }
    ]
  
  tags = {
    Name   = "Nexus"
  }
}
# module "sonarqube" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   name = "sonarqube"

#   instance_type          = "t3.medium"
#   vpc_security_group_ids = ["sg-06b1b57b365846051"] #replace your SG
#   ami                   = data.aws_ami.sonarqube_ami_info.id
#   #ami                   = "ami-0649f08ef033b0cc2"
#   key_name = aws_key_pair.tools.key_name
   
#     root_block_device = [
#     {
#       volume_type = "gp3"
#       volume_size = 50
#     }
#     ]
  
#   tags = {
#     Name   = "SonarQube"
#   }
# }

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"
  zone_name = var.zone_name


records = [
      {
        name = "jenkins_master"
        type = "A"
        ttl  = 1
        records = [
          module.jenkins_master.public_ip
        ]
       # allow_overwrite = true
      },
      {
        name = "jenkins_agent"
        type = "A"
        ttl  = 1
        records = [
          module.jenkins_agent.public_ip
        ]
        #allow_overwrite = true
       },
        {
        name = "nexus"
        type = "A"
        ttl  = 1
        records = [
          module.nexus.public_ip
        ]
        #allow_overwrite = true
      } #,
      # {
      #   name = "sonarqube"
      #   type = "A"
      #   ttl  = 1
      #   records = [
      #     module.sonarqube.public_ip
      #   ]
      #   #allow_overwrite = true
      # }
   ]
}













