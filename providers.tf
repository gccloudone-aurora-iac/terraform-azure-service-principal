# Providers

terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.22.0"
    }
  }
}
