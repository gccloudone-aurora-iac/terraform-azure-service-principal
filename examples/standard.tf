provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azuread_client_config" "this" {}

#############
### Users ###
#############

data "azuread_domains" "example" {
  only_initial = true
}

resource "azuread_user" "user1" {
  display_name        = "User1"
  password            = "SecretP@sswd99!"
  user_principal_name = "user1@${data.azuread_domains.example.domains.0.domain_name}"
}

resource "azuread_user" "user2" {
  display_name        = "User2"
  password            = "SecretP@sswd99!"
  user_principal_name = "user2@${data.azuread_domains.example.domains.0.domain_name}"
}

resource "azuread_user" "user3" {
  display_name        = "User3"
  password            = "SecretP@sswd99!"
  user_principal_name = "user3@${data.azuread_domains.example.domains.0.domain_name}"
}

resource "azuread_user" "user4" {
  display_name        = "User4"
  password            = "SecretP@sswd99!"
  user_principal_name = "user4@${data.azuread_domains.example.domains.0.domain_name}"
}

#############
### Module ###
#############

# Invokes the terraform-azurerm-service-principal module to create a service principal
#
# https://github.com/gccloudone-aurora-iac/terraform-azurerm-service-principal
#
module "example_sp" {
  source = "../"

  azure_resource_attributes = {
    project     = "aur"
    environment = "dev"
    location    = "Canada Central"
    instance    = 0
  }

  user_defined = "test"
  owners       = [data.azuread_client_config.this.object_id]

  web_redirect_uris       = ["https://login.live.com/oauth20_desktop.srf"]
  group_membership_claims = ["ApplicationGroup"]
  optional_claims = {
    access_tokens = [{
      name = "groups"
    }]
    id_tokens = [{
      name = "groups"
    }]
    saml2_tokens = [{
      name = "groups"
    }]
  }

  roles_and_members = {
    Grafana_Viewer = {
      description = "description test"
      value       = "Viewer"
      members = {
        user1 = azuread_user.user1.object_id
        user2 = azuread_user.user2.object_id
      }
    }
    Grafana_Editor = {
      description = "description test"
      value       = "Editor"
      members = {
        user3 = azuread_user.user3.object_id
        user4 = azuread_user.user4.object_id
      }
    }
  }
}
