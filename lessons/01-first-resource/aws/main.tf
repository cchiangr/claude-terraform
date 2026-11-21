resource "random_pet" "suffix" {
  length = 2
}

resource "aws_s3_bucket" "assets" {
  bucket = "little-gamestore-assets-${random_pet.suffix.id}"
}

resource "aws_s3_object" "logo" {
  bucket       = aws_s3_bucket.assets.id
  key          = "brand/logo.svg"
  source       = "${path.module}/assets/logo.svg"
  content_type = "image/svg+xml"
  etag         = filemd5("${path.module}/assets/logo.svg")
}

resource "aws_s3_object" "text" {
  bucket       = aws_s3_bucket.assets.id
  key          = "brand/welcome.txt"
  source       = "${path.module}/assets/welcome.txt"
  content_type = "text/plain"
  etag         = filemd5("${path.module}/assets/welcome.txt")
}