#Get Linux AMI ID using SSM parameters endpoint us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Get Linux AMI ID using SSM parameters endpoint us-west-1
data "aws_ssm_parameter" "linuxAmiCa" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Craete key-pair for logging into Ec2 in us-east-1
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Craete key-pair for logging into Ec2 in us-west-1
resource "aws_key_pair" "worker-key" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "jenkins_master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id

  tags = {
    Name = "jenkins_master_tf"
  }

  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id}
ansible-playbook --extra-var 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templets/jenkins-master-sample.yml
EOF
  }  
}








#Create and bootstrap EC2 in us-west-1
resource "aws_instance" "jenkins_worker_ca" {
  provider                    = aws.region-worker
  count                       = var.workers-count
  ami                         = data.aws_ssm_parameter.linuxAmiCa.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.worker-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg-ca.id]
  subnet_id                   = aws_subnet.subnet_1_cali.id

  tags = {
    Name = join("_", ["jenkins_worker_tf", count.index + 1])
  }

  depends_on = [aws_main_route_table_association.set-worker-default-rt-assoc, aws_instance.jenkins_master]

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-worker} --instance-ids ${self.id}
ansible-playbook --extra-var 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templets/jenkins-worker-sample.yml
EOF
  } 

}
