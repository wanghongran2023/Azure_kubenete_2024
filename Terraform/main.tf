terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  subscription_id = var.provider_credentials.subscription_id
  tenant_id       = var.provider_credentials.tenant_id
  client_id       = var.provider_credentials.sp_client_id
  client_secret   = var.provider_credentials.sp_client_secret
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_config.name
  location = var.resource_group_config.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_config.name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}

resource "azurerm_service_plan" "service_plan" {
  name                = "service-plan"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku_name            = "P0v3"
  os_type             = "Linux"
}

resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = var.cosmos_config.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.resource_group.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "cosmos_db" {
  name                = var.cosmos_config.db_name
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
}

resource "azurerm_cosmosdb_mongo_collection" "collection1" {
  name                = var.cosmos_config.collection1_name
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_mongo_database.cosmos_db.name
  shard_key           = "shardKey"
  throughput          = 400
  index {
    keys    = ["_id"]
    unique  = true
  }
}

resource "azurerm_cosmosdb_mongo_collection" "collection2" {
  name                = var.cosmos_config.collection2_name
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_mongo_database.cosmos_db.name
  shard_key           = "shardKey"
  throughput          = 400
  index {
    keys = ["_id"]
    unique  = true
  }
}

resource "azurerm_linux_function_app" "function" {
  name                = var.function_config.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  service_plan_id = azurerm_service_plan.service_plan.id
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key

  site_config {
    always_on        = true
    application_stack {
      python_version = "3.9"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    MONGODB_CONNECTION_STRING = azurerm_cosmosdb_account.cosmos_account.connection_strings[0]
  }
}

output "cosmos_db_connection_string" {
  value     = azurerm_cosmosdb_account.cosmos_account.connection_strings[0]
  sensitive = true
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_config.name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
  sensitive = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_config.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = "exampleaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_role_assignment" "aks_acr_permission" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "python-app-service-plan"
  location            = azurerm_resource_group.cms.location
  resource_group_name = azurerm_resource_group.cms.name
  sku_name            = "P0v3"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "linux_webapp" {
  name                = var.app_config.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  auth_settings {
    enabled = false
  }
  
  site_config {
    always_on        = true
    #app_command_line = "apt-get update && apt-get install -y build-essential g++ && pip install -r requirements.txt && python application.py"

    app_command_line = "apt-get update && apt-get install -y build-essential g++ && pip install -r requirements.txt && pip install -r gunicorn && gunicorn --bind 0.0.0.0:8000 --workers 3 FlaskWebProject:app"
    application_stack {
      python_version = "3.9"
    }
  }

  app_settings = { 
  }
}
