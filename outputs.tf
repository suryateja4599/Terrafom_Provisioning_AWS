output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins_master.public_ip
}

output "Jenkins-worker-public-IPs" {
  value = {
    for instance in aws_instance.jenkins_worker_ca :
    instance.id => instance.public_ip
  }
}

#04/08/2023
#LB DNS name to outputs

output "LB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name
}