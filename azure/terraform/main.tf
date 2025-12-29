terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "res-grp" {
  name     = "rg-cloud-resume-azure"
  location = "westus"
}

# Random suffix for globally-unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------
# Frontend: Azure Storage Static Website
# -----------------------------
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

output "website_url" {
  description = "The URL of the static website hosted on the Storage Account"
  value       = azurerm_storage_account.resume_storage.primary_web_endpoint
}

# -----------------------------
# Backend Data: Cosmos DB (Serverless)
# -----------------------------
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

  # Your container uses /id as the partition key (matches your screenshot and your working SDK code)
  partition_key_path = "/id"
}

# -----------------------------
# DNS Zone (Domain: ma-resume.org)
# -----------------------------
resource "azurerm_dns_zone" "resume_dns" {
  name                = "ma-resume.org"
  resource_group_name = azurerm_resource_group.res-grp.name
}

# -----------------------------
# Backend API Host: Azure Static Web App (API-only)
# This replaces Azure Function App + App Service Plan (quota blocked).
# -----------------------------
resource "azurerm_static_web_app" "counter_api" {
  name                = "swa-counter-api-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.res-grp.name
  location            = "westus2"

  sku_tier = "Free"
  sku_size = "Free"
}

output "counter_api_default_host_name" {
  description = "Static Web App hostname. Your API will be at: https://<host>/api/GetResumeCounter"
  value       = azurerm_static_web_app.counter_api.default_host_name
}

output "counter_api_deploy_token" {
  description = "Deployment token for GitHub Actions (store as repo secret)"
  value       = azurerm_static_web_app.counter_api.api_key
  sensitive   = true
}
