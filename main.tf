###################
### Application ###
###################

resource "azuread_application_registration" "this" {
  display_name = var.user_defined != null ? "${module.azure_resource_prefixes.service_principal_prefix}-${var.user_defined}" : module.azure_resource_prefixes.service_principal_prefix
  description  = var.description
  notes        = var.notes

  group_membership_claims = var.group_membership_claims
}

resource "azuread_application_redirect_uris" "web" {
  count = length(var.web_redirect_uris) > 0 ? 1 : 0

  application_id = azuread_application_registration.this.id
  type           = "Web"
  redirect_uris  = var.web_redirect_uris
}

resource "azuread_application_optional_claims" "this" {
  count = var.optional_claims != null ? 1 : 0

  application_id = azuread_application_registration.this.id

  dynamic "access_token" {
    for_each = var.optional_claims.access_tokens
    content {
      name                  = access_token.value.name
      additional_properties = access_token.value.additional_properties
      essential             = access_token.value.essential
      source                = access_token.value.source
    }
  }

  dynamic "id_token" {
    for_each = var.optional_claims.id_tokens
    content {
      name                  = id_token.value.name
      additional_properties = id_token.value.additional_properties
      essential             = id_token.value.essential
      source                = id_token.value.source
    }
  }

  dynamic "saml2_token" {
    for_each = var.optional_claims.saml2_tokens
    content {
      name                  = saml2_token.value.name
      additional_properties = saml2_token.value.additional_properties
      essential             = saml2_token.value.essential
      source                = saml2_token.value.source
    }
  }
}

### Password ###

# Manages a rotating time resource, which keeps a rotating UTC timestamp stored in the Terraform state and proposes resource recreation
# when the locally sourced current time is beyond the rotation time. This rotation only occurs when Terraform is executed.
#
resource "time_rotating" "application_password" {
  count = var.application_password.rotation_days != null ? 1 : 0

  rotation_days = var.application_password.rotation_days
}

resource "azuread_application_password" "this" {
  count = var.application_password.enable ? 1 : 0

  application_id = azuread_application_registration.this.id

  rotate_when_changed = var.application_password.rotation_days != null ? {
    rotation = time_rotating.application_password[0].id
  } : null
}

### App Roles ###

resource "random_uuid" "app_roles" {
  for_each = var.roles_and_members
}

resource "azuread_application_app_role" "this" {
  for_each = var.roles_and_members

  application_id = azuread_application_registration.this.id
  role_id        = random_uuid.app_roles[each.key].id

  display_name         = replace(each.key, "_", " ")
  description          = each.value.description
  allowed_member_types = each.value.allowed_member_types
  value                = each.value.value
}

#########################
### Service Principal ###
#########################

resource "azuread_service_principal" "this" {
  client_id = azuread_application_registration.this.client_id
  owners    = local.owners
}

resource "azuread_app_role_assignment" "this" {
  for_each = local.role_to_member_map

  resource_object_id  = azuread_service_principal.this.object_id
  app_role_id         = azuread_application_app_role.this[each.value.role_display_name].role_id
  principal_object_id = each.value.member_object_id
}
