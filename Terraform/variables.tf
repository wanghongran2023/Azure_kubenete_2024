variable "provider_credentials" {
  type = object({
    subscription_id  = string
    tenant_id        = string
    sp_client_id     = string
    sp_client_secret = string
  })
}

variable "resource_group_config" {
  type = object({
    name             = string
    location         = string
  })
}

variable "storage_account_config" {
  type = object({
    name             = string
  })
}

variable "function_config" {
  type = object({
    name             = string
  })
}

variable "cosmos_config" {
  type = object({
    name        	         = string
    db_name             	 = string
    collection1_name             = string
    collection2_name             = string
  })
}

variable "acr_config" {
  type = object({
    name             = string
  })
}

variable "aks_config" {
  type = object({
    name             = string
  })
}

variable "app_config" {
  type = object({
    name             = string
  })
}
