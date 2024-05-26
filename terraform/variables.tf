variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"  # or any default region you prefer
}

variable "branch_name" {
  description = "The branch name"
  type        = string
}

variable "tmdb_api_key" {
  description = "TMDB API key"
  type        = string
}
