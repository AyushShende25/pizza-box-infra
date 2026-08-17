terraform {
  backend "s3" {
    bucket       = "pizzabox.fullstackprojects.dev-remote-backend"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
