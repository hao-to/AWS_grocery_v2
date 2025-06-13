resource "aws_s3_bucket" "avatars" {
  bucket = "haos-grocery-avatars"

  tags = {
    Name        = "haos-grocery-avatars"
    Environment = "Dev"
  }
}
