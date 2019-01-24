resource "tls_private_key" "priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "hyperflow_runner"
  public_key = "${tls_private_key.priv_key.public_key_openssh}"
}
