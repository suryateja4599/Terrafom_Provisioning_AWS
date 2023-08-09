#ACM Configuration
#Create ACM certificate and requests validation via DNS(Route53)
resource "aws_acm_certificate" "jenkins-lb-https" {
	provider = aws.region-master
	domain_name = join (".", ["jenkins", data.aws_route53_zone.dns.name])
	validation_methode = "DNS"
	tags = {
		Name = "jenkins-ACM"
	}
}

#Validate ACM issued certificate via Route50
resource "aws_acm_certificate_validation" "cert" {
	provider = aws.region-master
	certification_arn = aws_acm_certification.jenkins-lb-https.arn
	for _each = aws_route53_record.cert_validation
	Validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}