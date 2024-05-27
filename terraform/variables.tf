variable "branch_name" {
  description = "The name of the Git branch."
}

variable "aws_region" {
  description = "AWS region."
}

variable "tmdb_api_key" {
  description = "TMDB API key."
}

variable "timestamp" {
  description = "Timestamp for resource naming."
  default     = "20240527-024209"
}
