# -----------------------------------------------------------------------------
# Bucket used for storing front end content
resource "aws_s3_bucket" "www-jungle-meet-com" {
  bucket = "www.${var.domain_name}"
}

data "aws_iam_policy_document" "www-jungle-meet-com" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::www.${var.domain_name}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.jungle-meet-com.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "www-jungle-meet-com" {
  bucket = aws_s3_bucket.www-jungle-meet-com.id
  policy = data.aws_iam_policy_document.www-jungle-meet-com.json

}
