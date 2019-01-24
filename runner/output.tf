output "public_dns" {
  value = "${aws_instance.hyperflow_runner.public_dns}"
}
