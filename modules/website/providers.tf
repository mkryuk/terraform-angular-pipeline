
# The provider below is required to handle ACM and Lambda in a CloudFront context
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}