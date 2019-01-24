resource "null_resource" "job" {
  # Changes to runner instance requires re-provisioning
  triggers {
    cluster_instance_ids = "${aws_instance.hyperflow_runner.id}"
    uploaded_s3 = "${null_resource.upload_to_s3.id}"
  }

  connection {
    host = "${aws_instance.hyperflow_runner.public_ip}"
    user        = "ubuntu"
    private_key = "${tls_private_key.priv_key.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run -v /home/ubuntu/workdir:/workdir -e AMQP_URL='${local.AMQP_URL}' -e AWS_ACCESS_KEY_ID='${var.ACCESS_KEY}' -e AWS_SECRET_ACCESS_KEY='${var.SECRET_ACCESS_KEY}' -e S3_BUCKET='${aws_s3_bucket.job_bucket.bucket}' -e S3_PATH='input/' -e METRIC_COLLECTOR='${local.METRIC_COLLECTOR}' --net=host -it krysp89/hyperflow-hflow",
    ]
  }
}
