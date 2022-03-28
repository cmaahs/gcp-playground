# ------------------------------------------------------------------------------
# Common variables - will vary by environment
# ------------------------------------------------------------------------------
variable "region" {
  description = "The region the resources should be created in"
  type        = string
  default     = "us-east4"
}

variable "project_id" {
  description = "The gcp project id where the resources will be created"
  type        = string
}

variable "labels_owner" {
  description = "The department that is the owner of this resource"
  type        = string
  default     = "platform-apps"
}

variable "labels_purpose" {
  description = "The purpose of this.  Could be development / testing / production"
  type        = string
  default     = "testing"
}

variable "credentials_file" {
    type = string
}

