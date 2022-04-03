
output "Nombre-bucket-S3" {
  value = aws_s3_bucket.acme.id
}


output "URL-bucket-googleStorage" {
  value = google_storage_bucket.acme.url
}