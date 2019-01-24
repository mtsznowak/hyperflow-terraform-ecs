output "public_ip" {
  value = "${aws_instance.grafana_server.public_ip}"
}
