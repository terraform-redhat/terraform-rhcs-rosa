# Rosa HCP with public cluster with default iam\oidc\vpc resources created.

TODO

## Prerequisites

To use this you will need:

* The [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (1.2.0+) installed.
* The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
* [AWS account](https://aws.amazon.com/free/?all-free-tier) and [associated credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/security-creds.html) that allow you to create resources. The credentials configured for the AWS provider (see [Authentication and Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) section in AWS terraform provider documentations)
* The [ROSA CLI](https://docs.openshift.com/rosa/rosa_cli/rosa-get-started-cli.html) installed
* [OpenShift Cluster Manager API Token](https://console.redhat.com/openshift/token)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_rhcs"></a> [rhcs](#requirement\_rhcs) | >= 1.1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_iam_resources"></a> [account\_iam\_resources](#module\_account\_iam\_resources) | ../../modules/account-iam-resources | n/a |
| <a name="module_oidc_provider"></a> [oidc\_provider](#module\_oidc\_provider) | ../../modules/oidc-provider | n/a |
| <a name="module_operator_roles"></a> [operator\_roles](#module\_operator\_roles) | ../../modules/operator-roles | n/a |
| <a name="module_rosa_cluster_hcp"></a> [rosa\_cluster\_hcp](#module\_rosa\_cluster\_hcp) | ../../modules/rosa-cluster-hcp | n/a |
| <a name="module_unmanaged_oidc_config"></a> [unmanaged\_oidc\_config](#module\_unmanaged\_oidc\_config) | ../../modules/unmanaged-oidc-config | n/a |


## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:| 
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | `object` | `{}` | no |
| <a name="input_create_account_roles"></a> [create\_account\_roles](#input\_create\_account\_roles) | n/a | `bool` | `false` | no |
| <a name="input_create_operator_roles"></a> [create\_operator\_roles](#input\_create\_operator\_roles) | n/a | `bool` | `false` | no |
| <a name="input_create_oidc "></a> [create\_oidc](#input\_create\_oidc ) | n/a | `bool` | `false` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | n/a | `array` | `[]` | no |
| <a name="input_vpc_private_subnets_ids"></a> [vpc\_private\_subnets\_ids](#input\_vpc\_private\_subnets\_ids) | n/a | `array` | `[]` | no |
| <a name="input_vpc_public_subnets_ids"></a> [vpc\_public\_subnets\_ids](#input\_) | n/a | `array` | `[]` | no |
| <a name="input_machine_cidr"></a> [machine\_cidr](#input\_machine\_cidr) | n/a | `string` | `"10.0.0.0/16"` | no |
| <a name="input_oidc"></a> [oidc](#input\_oidc) | n/a | `string` | `"managed"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` |  | yes |
| <a name="input_hypershift_enabled"></a> [hypershift\_enabled](#input\_hypershift\_enabled) | n/a | `bool` | `true` | yes |
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id) | n/a | `string` |  | yes |
| <a name="input_admin_credentials"></a> [admin\_credentials](#input\_admin\_credentials) | n/a | `map(string)` | `{ username = "admin1", password = "123456!qwertyU" }` | no |
| <a name="input_ocm_environment"></a> [ocm\_environment](#input\_ocm\_environment) | n/a | `string` | `"production"` | no |
| <a name="input_openshift_version"></a> [openshift\_version](#input\_openshift\_version) | n/a | `string` | `"4.14.5"` | no |

## Outputs

No outputs.


