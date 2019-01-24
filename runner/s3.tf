resource "aws_s3_bucket" "job_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  force_destroy = true

  tags = {
    Name        = "Hyperflow bucket"
    Environment = "Dev"
  }
}

resource "null_resource" "upload_to_s3" {
  triggers {
    s3_bucket = "${var.bucket_name}"
    job_dir = "${var.job_directory}"
  }

  provisioner "local-exec" {
    command = "aws s3 sync ${var.job_directory} s3://${aws_s3_bucket.job_bucket.id}"
  }
}
