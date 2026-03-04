variable "resource_group_name" { type = string }
variable "prefix" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "storage_account_name_primary_connection_string" { type = string }
variable "storage_account_name" { type = string }