provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "hyperflow_runner" {
  ami = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = ["${aws_security_group.runner_security_group.id}"]
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"

  connection {
    user        = "ubuntu"
    private_key = "${tls_private_key.priv_key.private_key_pem}"
  }


  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ubuntu/workdir"
    ]
  }

  provisioner "file" {
    source      = "${var.JOB_DIRECTORY}/workdir/"
    destination = "/home/ubuntu/workdir"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install redis-server apt-transport-https ca-certificates curl software-properties-common  -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable\" -y",
      "sudo apt update",
      "sudo apt install docker-ce -y",
      "sudo systemctl enable redis",
      "nohup redis-server &",
    ]
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.hyperflow_runner.public_dns} > runner-dns.txt"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.priv_key.private_key_pem}' > priv_key.pem"
  }

}
