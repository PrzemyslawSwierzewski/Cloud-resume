variable "project_prefix" {
  description = "Short project prefix used in resource names (lowercase, no spaces)"
  type        = string
  default     = "res"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = { Environment = "dev", ManagedBy = "Terraform", Project = "static-site-poc" }
}

variable "custom_domain" {
  description = "(Optional) Custom domain to map to CDN endpoint (example: www.example.com)"
  type        = string
  default     = ""
}
