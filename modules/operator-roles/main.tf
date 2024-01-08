locals {
  hcp_operator_role_policy_arns = {
    "capa-controller-manager"     = "arn:aws:iam::aws:policy/service-role/ROSANodePoolManagementPolicy"
    "control-plane-operator"      = "arn:aws:iam::aws:policy/service-role/ROSAControlPlaneOperatorPolicy" 
    "kms-provider"                = "arn:aws:iam::aws:policy/service-role/ROSAKMSProviderPolicy"
    "kube-controller-manager"     = "arn:aws:iam::aws:policy/service-role/ROSAKubeControllerPolicy"
    "cloud-redentials"            = "arn:aws:iam::aws:policy/service-role/ROSACloudNetworkConfigOperatorPolicy" 
    "ebs-cloud-credentials"       = "arn:aws:iam::aws:policy/service-role/ROSAAmazonEBSCSIDriverOperatorPolicy"
    "installer-cloud-credentials" = "arn:aws:iam::aws:policy/service-role/ROSAImageRegistryOperatorPolicy"
    "cloud-credentials"           = "arn:aws:iam::aws:policy/service-role/ROSAIngressOperatorPolicy"
  }
  operator_roles_count = var.hypershift_enabled ? 8 : 6
}

data "rhcs_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = var.operator_role_prefix
  account_role_prefix  = var.account_role_prefix
  hypershift_enabled   = var.hypershift_enabled

  lifecycle {
    # The operator_iam_roles should contains 8 or 6 elements 
    postcondition {
      condition     = length(self.operator_iam_roles) == local.operator_roles_count
      error_message = "The list of operator roles should contains ${local.operator_roles_count} elements."
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "operator_role" {
  count = local.operator_roles_count

  name                 = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].role_name
  path                 = var.path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = data.aws_iam_policy_document.custom_trust_policy[count.index].json

  tags = var.hypershift_enabled ? merge(var.tags, {
      rosa_managed_policies  = true
      rosa_hcp_policies      = true
      red-hat-managed = true
      // TODO nargaman always empty?
      rosa_cluster_id    = var.cluster_id
      operator_namespace = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_namespace
      operator_name      = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_name
    }) : merge(var.tags, {
      red-hat-managed = true
      rosa_cluster_id    = var.cluster_id
      operator_namespace = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_namespace
      operator_name      = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_name
    })
}

resource "aws_iam_role_policy_attachment" "operator_role_policy_attachment" {
  count = local.operator_roles_count

  role       = aws_iam_role.operator_role[count.index].name
  policy_arn = var.hypershift_enabled ? local.hcp_operator_role_policy_arns["${data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_name}"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].policy_name}"
}

data "aws_iam_policy_document" "custom_trust_policy" {
  count = local.operator_roles_count

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_endpoint_url}"]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "${var.oidc_endpoint_url}:sub"
      values   = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].service_accounts
    }
  }
}
