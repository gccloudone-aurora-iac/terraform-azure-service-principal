variable "azure_resource_attributes" {
  description = "Attributes used to describe Azure resources"
  type = object({
    department_code = string
    owner           = string
    project         = string
    environment     = string
    location        = optional(string, "Canada Central")
    instance        = number
  })
  nullable = false
}

variable "user_defined" {
  description = "A user-defined field that describes the Azure resource."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.user_defined) >= 2 && length(var.user_defined) <= 15
    error_message = "The user-defined field must be between 2-15 characters long."
  }
}

variable "naming_convention" {
  type        = string
  default     = "oss"
  description = "Sets which naming convention to use. Accepted values: oss, gc"
  validation {
    condition     = var.naming_convention == "oss" || var.naming_convention == "gc"
    error_message = "The naming_convention field must either be 'oss' or 'gc'."
  }
}

variable "description" {
  description = "The user-defined segment that describes the purpose of the service principal."
  type        = string
  default     = null
}

variable "notes" {
  description = "The user-defined segment that describes the purpose of the service principal."
  type        = string
  default     = null
}

##################
### Appication ###
##################

variable "owners" {
  description = "A set of object IDs of principals that will be granted ownership of the application registration & service principal. Supported object types are users or service principals."
  type        = list(string)
  default     = []
}

variable "web_redirect_uris" {
  description = "The application's redirect URIs."
  type        = list(string)
  default     = []
}

variable "application_password" {
  description = "Specifies if a password will be created within the application registration and if so how often the secret will be rotated."
  type = object({
    enable        = optional(bool, true)
    rotation_days = optional(number, 365) # If null, the secret will never be rotated
  })
  default = {
    enable        = true
    rotation_days = 365
  }
}

variable "roles_and_members" {
  description = ""
  type = map(object({
    description          = optional(string)
    allowed_member_types = optional(list(string), ["User"])
    value                = optional(string)
    members              = map(string) // key is display name and value should be object ID
  }))
  default = {}
}

## Claims ##

variable "group_membership_claims" {
  description = "Configures the groups claim issued in a user or OAuth access token that the app expects. Possible values are None, SecurityGroup, DirectoryRole, ApplicationGroup or All."
  type        = list(string)
  default     = []
}

variable "optional_claims" {
  description = "Claims are pieces of information about a user, such as their username, email, or group membership, which are included in the security token issued by the identity provider after successful authentication."
  type = object({
    access_tokens = list(object({
      name                  = string
      additional_properties = optional(list(string))
      essential             = optional(bool)
      source                = optional(string)
    }))
    id_tokens = list(object({
      name                  = string
      additional_properties = optional(list(string))
      essential             = optional(bool)
      source                = optional(string)
    }))
    saml2_tokens = list(object({
      name                  = string
      additional_properties = optional(list(string))
      essential             = optional(bool)
      source                = optional(string)
    }))
  })
  default = null
}