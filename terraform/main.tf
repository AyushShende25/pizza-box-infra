resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket-17-08-2026"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
