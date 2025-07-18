module "jenkins_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "tf-jenkins-master"
  instance_type           = "t3.small"
  vpc_security_group_ids  = [var.allow_everything] #replace your SG
  ami                     = data.aws_ami.ami_info.id
  #ami                    = "ami-041e2ea9402c46c32"
  #subnet_id = "subnet-0ea509ad4cba242d7" #replace your default subnet id.
  #user_data              = file("install_jenkins_master.sh")
  user_data               = file("${path.module}/install_jenkins_master.sh")

  # Define the root volume size and type
  root_block_device {
    encrypted             = false
    volume_type           = "gp3"
    volume_size           = 50
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

  tags = {
    Name   = "Jenkins-Master"
  }
}
module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "tf-jenkins-agent"
  instance_type           = "t3.small"
  vpc_security_group_ids  = [var.allow_everything] #replace your SG
  ami                     = data.aws_ami.ami_info.id
  #ami                    = "ami-041e2ea9402c46c32"
   #subnet_id = "subnet-0ea509ad4cba242d7" #replace your default subnet id.
  #user_data              = file("install_jenkins_agent.sh")
  user_data               = file("${path.module}/install_jenkins_agent.sh")

   # Define the root volume size and type
  root_block_device {
    encrypted             = false
    volume_type           = "gp3"
    volume_size           = 50
    iops                  = 3000
    throughput            = 100
    delete_on_termination = true
  }

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
  vpc_security_group_ids = [var.allow_everything] #replace your SG
  ami                    = data.aws_ami.nexus_ami_info.id
  key_name               = aws_key_pair.tools.key_name
   
  # Define the root volume size and type
  root_block_device = [
    {
      volume_size = 30       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]
  
  tags = {
    Name   = "Nexus"
  }
}
module "sonarqube" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "sonarqube"

  instance_type          = "t3.medium"
  vpc_security_group_ids = [var.allow_everything] #replace your SG
  ami                   = data.aws_ami.sonarqube_ami_info.id
  #ami                   = "ami-0649f08ef033b0cc2"
  key_name = aws_key_pair.tools.key_name
   
  # Define the root volume size and type
  root_block_device = [
    {
      volume_size = 50       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]
  
  tags = {
    Name   = "SonarQube"
  }
}

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
        allow_overwrite = true
      },
      {
        name = "jenkins_agent"
        type = "A"
        ttl  = 1
        records = [
          module.jenkins_agent.public_ip
        ]
        allow_overwrite = true
        }
        ,
        {
        name = "nexus"
        type = "A"
        ttl  = 1
        records = [
          module.nexus.public_ip
        ]
        allow_overwrite = true
      } ,
      {
        name = "sonarqube"
        type = "A"
        ttl  = 1
        records = [
          module.sonarqube.public_ip
        ]
        allow_overwrite = true
      }
   ]
}