resource "time_sleep" "wait_10_seconds" {
  destroy_duration = "30s"
}

locals {
  short_openshift_version = format("%s.%s", split(".", var.openshift_version)[0], split(".", var.openshift_version)[1])
  account_roles_properties = [
    {
      role_name            = var.hypershift_enabled ? "HCP-ROSA-Installer" : "Installer"
      role_type            = "installer"
      policy_details       = data.rhcs_policies.all_policies.account_role_policies["sts_installer_permission_policy"]
      principal_type       = "AWS"
      principal_identifier = "arn:aws:iam::${data.rhcs_info.current.ocm_aws_account_id}:role/RH-Managed-OpenShift-Installer"
      aws_policy_arn       = "arn:aws:iam::aws:policy/service-role/ROSAInstallerPolicy"
    },
    {
      role_name            = var.hypershift_enabled ? "HCP-ROSA-Support" : "Support"
      role_type            = "support"
      policy_details       = data.rhcs_policies.all_policies.account_role_policies["sts_support_permission_policy"]
      principal_type       = "AWS"
      principal_identifier = "arn:aws:iam::${data.rhcs_info.current.ocm_aws_account_id}:role/RH-Technical-Support-Access"
      aws_policy_arn       = "arn:aws:iam::aws:policy/service-role/ROSASRESupportPolicy"
    },
    {
      role_name            = var.hypershift_enabled ? "HCP-ROSA-Worker" : "Worker"
      role_type            = "worker"
      policy_details       = data.rhcs_policies.all_policies.account_role_policies["sts_instance_worker_permission_policy"]
      principal_type       = "Service"
      principal_identifier = "ec2.amazonaws.com"
      aws_policy_arn       = "arn:aws:iam::aws:policy/service-role/ROSAWorkerInstancePolicy"
    },
    {
      role_name            = var.hypershift_enabled ? "HCP-ROSA-ControlPlane" : "ControlPlane"
      role_type            = "controlplane"
      policy_details       = data.rhcs_policies.all_policies.account_role_policies["sts_instance_controlplane_permission_policy"]
      principal_type       = "Service"
      principal_identifier = "ec2.amazonaws.com"
      aws_policy_arn       = "arn:aws:iam::aws:policy/service-role/ROSAControlPlaneOperatorPolicy"
    }
  ]
  account_roles_count = null_resource.validate_openshift_version != null ? length(local.account_roles_properties) : 0
}

data "aws_iam_policy_document" "custom_trust_policy" {
  count = local.account_roles_count

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = local.account_roles_properties[count.index].principal_type
      identifiers = [local.account_roles_properties[count.index].principal_identifier]
    }
  }
}

module "account_iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  count  = local.account_roles_count

  create_role = true

  role_name = "${local.account_role_prefix_valid}-${local.account_roles_properties[count.index].role_name}-Role"

  role_path                     = var.path
  role_permissions_boundary_arn = var.permissions_boundary

  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.custom_trust_policy[count.index].json

  custom_role_policy_arns = var.hypershift_enabled ? [local.account_roles_properties[count.index].aws_policy_arn] : [module.account_iam_policy[count.index].arn]

  tags = var.hypershift_enabled ? merge(var.tags, {
      rosa_managed_policies  = true
      rosa_hcp_policies      = true
      red-hat-managed        = true
      rosa_openshift_version = local.short_openshift_version
      rosa_role_prefix       = "${local.account_role_prefix_valid}"
      rosa_role_type         = "${local.account_roles_properties[count.index].role_type}"
    }) : merge(var.tags, {
      red-hat-managed        = true
      rosa_openshift_version = local.short_openshift_version
      rosa_role_prefix       = "${local.account_role_prefix_valid}"
      rosa_role_type         = "${local.account_roles_properties[count.index].role_type}"
    })
}

module "account_iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  count  = var.hypershift_enabled ? 0 : local.account_roles_count

  name = "${local.account_role_prefix_valid}-${local.account_roles_properties[count.index].role_name}-Role-Policy"

  policy = local.account_roles_properties[count.index].policy_details

  tags = merge(var.tags, {
    rosa_openshift_version = local.short_openshift_version
    rosa_role_prefix       = "${local.account_role_prefix_valid}"
    rosa_role_type         = "${local.account_roles_properties[count.index].role_type}"
  })
}

data "rhcs_policies" "all_policies" {}

data "rhcs_versions" "all_versions" {}

resource "random_string" "default_random" {
  count = var.account_role_prefix != null ? 0 : 1

  length  = 4
  special = false
  upper   = false
}

locals {
  patch_version_list        = [for s in data.rhcs_versions.all_versions.items : s.name]
  minor_version_list        = local.patch_version_list != [] ? distinct([for s in local.patch_version_list : format("%s.%s", split(".", s)[0], split(".", s)[1])]) : []
  account_role_prefix_valid = var.account_role_prefix != null ? var.account_role_prefix : "account-role-${random_string.default_random[0].result}"
}

data "rhcs_info" "current" {}

resource "null_resource" "validate_openshift_version" {
  lifecycle {
    precondition {
      condition     = contains(local.minor_version_list, local.short_openshift_version)
      error_message = "ERROR: Expected a valid OpenShift version. Valid versions: ${join(", ", local.minor_version_list)}"
    }
  }
}
