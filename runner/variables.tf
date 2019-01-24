variable "BUCKET_NAME" {
  default = "hyperflow-1111"
}

variable "JOB_DIRECTORY" {
  default = ""
}

variable "AMQP_URL" {
  default = ""
}

variable "METRIC_COLLECTOR" {
  default = ""
}

variable "ACCESS_KEY" {
  default = ""
}

variable "SECRET_ACCESS_KEY" {
  default = ""
}

locals {
  AMQP_URL = "${var.AMQP_URL != "" ? var.AMQP_URL : format("%s%s%s", "amqp://", trimspace(file("../infrastructure/master-dns.txt")), ":5672")}"
  METRIC_COLLECTOR = "${var.METRIC_COLLECTOR != "" ? var.METRIC_COLLECTOR : format("%s%s%s", "http://", trimspace(file("../infrastructure/master-dns.txt")), ":8086/hyperflow_tests")}"
}
