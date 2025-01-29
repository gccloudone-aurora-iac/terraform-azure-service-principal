locals {
  owners = distinct(concat(var.owners, [data.azuread_client_config.this.object_id]))

  role_to_member_list = flatten([
    for name, value in var.roles_and_members : [
      for member_display_name, member_object_id in value.members : {
        role_display_name   = name
        member_object_id    = member_object_id
        member_display_name = member_display_name
      }
    ]
  ])

  role_to_member_map = {
    for value in local.role_to_member_list : lower("${value.role_display_name}_${value.member_display_name}") => {
      member_object_id  = value.member_object_id
      role_display_name = value.role_display_name
    }
  }
}
