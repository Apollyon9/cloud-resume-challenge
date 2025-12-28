terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "res-grp" {
  name     = "rg-cloud-resume-azure"
  location = "eastus"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "resume_storage" {
  name                     = "stcloudresume${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.res-grp.name
  location                 = azurerm_resource_group.res-grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = "cosmos-resume-${random_string.suffix.result}"
  location            = azurerm_resource_group.res-grp.location
  resource_group_name = azurerm_resource_group.res-grp.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.res-grp.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "AzureResume"
  resource_group_name = azurerm_resource_group.res-grp.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
}

resource "azurerm_cosmosdb_sql_container" "counter_container" {
  name                = "Counter"
  resource_group_name = azurerm_resource_group.res-grp.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/id"
}

output "website_url" {
  description = "The URL of the static website"
  value       = azurerm_storage_account.resume_storage.primary_web_endpoint
}

resource "azurerm_dns_zone" "resume_dns" {
  name                = "ma-resume.org"
  resource_group_name = azurerm_resource_group.res-grp.name
}