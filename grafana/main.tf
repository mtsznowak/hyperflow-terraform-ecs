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

resource "aws_instance" "grafana_server" {
    ami = "${data.aws_ami.ubuntu.id}"
    vpc_security_group_ids = ["${aws_security_group.grafana_security_group.id}"]
    instance_type = "t2.micro"
    key_name      = "${aws_key_pair.generated_key.key_name}"

  connection {
    user         = "ubuntu"
    private_key = "${tls_private_key.priv_key.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install docker-compose -y"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/hyperflow-wms/hyperflow-grafana.git --recurse-submodules",
      "cd hyperflow-grafana",
      "sudo docker-compose up -d"
    ]
  }

  # Save the public IP
  provisioner "local-exec" {
    command = "echo ${aws_instance.grafana_server.public_dns} > grafana-dns.txt"
  }

}
