data "tls_certificate" "provider" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  thumbprint_list = [data.tls_certificate.provider.certificates[0].sha1_fingerprint]

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags = {
    Service   = "github-actions"
    ManagedBy = "terraform"
  }
}




