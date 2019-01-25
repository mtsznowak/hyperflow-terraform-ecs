resource "aws_s3_bucket" "job_bucket" {
  bucket = "${var.BUCKET_NAME}"
  acl    = "private"
  force_destroy = true

  tags = {
    Name        = "Hyperflow bucket"
    Environment = "Dev"
  }
}

resource "null_resource" "upload_to_s3" {
  triggers {
    s3_bucket = "${var.BUCKET_NAME}"
    job_dir = "${var.JOB_DIRECTORY}"
  }

  provisioner "local-exec" {
   command = "aws s3 sync ${var.JOB_DIRECTORY} s3://${aws_s3_bucket.job_bucket.id}"
  }
}
