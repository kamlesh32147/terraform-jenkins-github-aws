provider "aws" {
  region = "ap-south-1"
  profile = "default"
}

# creating key pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = "deploy-key"
  public_key = tls_private_key.key.public_key_openssh
}

# saving key to local file
resource "local_file" "deploy-key" {
    content  = tls_private_key.key.private_key_pem
    filename = "/root/terra/task1/deploy-key.pem"
    file_permission = "0400"
}

resource "aws_security_group" "terraform_sg" {
  name        = "terraform"
  description = "Allow http and ssh inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_from_terraform"
  }
}

resource "aws_instance" "terraform_ec2" {
  ami             = "ami-0447a12f28fddb066"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = ["terraform"]

  depends_on = [ local_file.deploy-key, aws_security_group.terraform_sg ]
  tags = {
    Name = "terraform"
  }
}


               resource "aws_ebs_volume" "terraform_ebs" {
  availability_zone = aws_instance.terraform_ec2.availability_zone
  size              = 1

 tags = {
    Name = "for_terraform"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.terraform_ebs.id
  instance_id = aws_instance.terraform_ec2.id
  force_detach = true
}

resource "null_resource" "ssh_ec2" {
depends_on = [
  aws_volume_attachment.ebs_att,
  local_file.deploy-key,
]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("/root/terra/task1/deploy-key.pem")
    host = aws_instance.terraform_ec2.public_ip
}

provisioner "remote-exec" {
  inline = [
    "sudo yum install httpd -y",
    "sudo systemctl start httpd",                                                                                                                         "sudo mkfs.ext4 /dev/xvdf",
    "sudo mount /dev/xvdf /var/www/html",
    "sudo yum install git -y",
    "sudo rm -rf /var/www/html/*",
    "sudo git clone https://github.com/kamlesh32147/devweb.git /var/www/html",
    ]
  }
}


resource "aws_s3_bucket" "terra_s3" {
  bucket = "kamleshtfs3"
  acl    = "public-read"
  tags = {
    Name        = "My bucket"
  }
}


resource "null_resource" "upload_to_s3" {
    depends_on = [ aws_s3_bucket.terra_s3, ]
    provisioner "local-exec" {
      command = "git clone https://github.com/kamlesh32147/s3.git /root/terra/s3"
      }
    provisioner "local-exec" {

      command = "aws s3 sync /root/terra/s3 s3://kamleshtfs3/"
      }
    provisioner "local-exec" {

      command = "aws s3api put-object-acl --bucket kamleshtfs3 --key alibaba_alb.png --acl public-read"
    }
}


# Create Cloudfront distribution
resource "aws_cloudfront_distribution" "distribution" {
    origin {
        domain_name = "${aws_s3_bucket.terra_s3.bucket_regional_domain_name}"
        origin_id = "S3-${aws_s3_bucket.terra_s3.bucket}"

        custom_origin_config {
                                                                                                                                    138,1         63%
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }
    # By default, show index.html file
    default_root_object = "index.html"
    enabled = true


    # If there is a 404, return index.html with a HTTP 200 Response
    custom_error_response {
        error_caching_min_ttl = 3000
        error_code = 404
        response_code = 200
        response_page_path = "/index.html"
    }


    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-${aws_s3_bucket.terra_s3.bucket}"


        #Not Forward all query strings, cookies and headers
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }

        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }


    # Distributes content to all
    price_class = "PriceClass_All"


    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }


    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

                                                                                                                                    174,1-8       85%



                                                                                                                                    67,0-1        21%
                                                                                                                                    1,1           Top
