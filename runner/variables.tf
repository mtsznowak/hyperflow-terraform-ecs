variable "bucket_name" {
  default = "hyperflow-1111"
}

variable "job_directory" {
  default = ""
}

variable "amqp_url" {
  default = ""
}

variable "metric_collector" {
  default = ""
}

variable "access_key" {
  default = ""
}

variable "secret_access_key" {
  default = ""
}

locals {
  amqp_url = "${var.amqp_url != "" ? var.amqp_url : format("%s%s%s", "amqp://", trimspace(file("../infrastructure/master-dns.txt")), ":5672")}"
  metric_collector = "${var.metric_collector != "" ? var.metric_collector : format("%s%s%s", "http://", trimspace(file("../infrastructure/master-dns.txt")), ":8086/hyperflow_tests")}"
}
