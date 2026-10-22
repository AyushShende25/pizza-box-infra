resource "aws_iam_openid_connect_provider" "github_actions" {
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags = {
    Service   = "github-actions"
    ManagedBy = "terraform"
  }
}




