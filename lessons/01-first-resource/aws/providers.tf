provider "aws" {
  region  = "eu-central-1"
  profile = "carlos-cli"

  default_tags {
    tags = {
      Project   = "the-little-gamestore"
      ManagedBy = "terraform"
      Lesson    = "01"
    }
  }
}
