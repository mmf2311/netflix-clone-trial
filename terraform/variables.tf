variable "aws_region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "branch_name" {
  description = "The name of the Git branch being deployed."
}

variable "tmdb_api_key" {
  description = "The API key for TMDB."
  type        = string
}
