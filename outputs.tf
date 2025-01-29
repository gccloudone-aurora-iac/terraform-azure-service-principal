output "application_registration" {
  description = "The application registration details"
  value       = azuread_application_registration.this
}

output "service_principal" {
  description = "The object ID of the service principal."
  value       = azuread_service_principal.this
}

output "application_registration_password" {
  description = "The application_registration password"
  value       = var.application_password.enable ? azuread_application_password.this[0] : null
}
