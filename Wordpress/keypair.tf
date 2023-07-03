resource "tls_private_key" "WordpressKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "AWSWordpressKey" {
  key_name   = "AWSWordpressKey"     
  public_key = tls_private_key.WordpressKey.public_key_openssh

  provisioner "local-exec" { 
    command = "echo '${tls_private_key.WordpressKey.private_key_pem}' > ./PrivateKey.pem"
  }
}