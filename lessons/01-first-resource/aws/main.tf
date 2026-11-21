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
