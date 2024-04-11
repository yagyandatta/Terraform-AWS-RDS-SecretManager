######## AWS ###########
variable "region" {
  type = string
  description = "The AWS region where the secret should be created"
}


######## APPLICATION ###########

variable "application_name" {
  type = string
  description = "The name of the application using the secret"
}

variable "environment" {
  type = string
  description = "The deployment environment (e.g., dev, prod)"
}

variable "secret_intent" {
  type = string
  description = "The reason for creating the secret (e.g., db-password, api-key)"
}


######## Tags ###########
variable "tags" {
  type = map(string)
  description = "A map of key-value pairs to be applied as tags to the secret"
  default = {}
}
