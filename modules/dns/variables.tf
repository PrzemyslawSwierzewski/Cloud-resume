variable "resource_group_name" { type = string }
variable "prefix" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "custom_domain" { type = string }
variable "cdn_endpoint_hostname" { type = string }
