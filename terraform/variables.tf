variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "tmdb_api_key" {
  description = "Your TMDB API key"
}

variable "timestamp" {
  description = "Timestamp for unique naming"
  default     = formatdate("YYYYMMDD-HHMMSS", timestamp())
}
