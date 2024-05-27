variable "branch_name" {
  description = "The name of the Git branch."
}

variable "aws_region" {
  description = "AWS region."
  default     = "us-east-1"
}

variable "tmdb_api_key" {
  description = "TMDB API key."
}
