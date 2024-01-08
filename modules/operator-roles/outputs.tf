output "operator_role_prefix" {
  value = var.operator_role_prefix
}

output "operator_roles_arn" {
  value = { for idx, val in aws_iam_role.operator_role : data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[idx].service_accounts[0] => val.arn }
}
