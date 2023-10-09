# GCP FortiSASE PoC

## How do you run these?

1. Install [Terraform](https://www.terraform.io/).
1. Open `terraform.tfvars`,  and fill in required variables that don't have a default. (CREDENTIALS, GCP_PROJECT, SERVICE_ACCOUNT_EMAIL, IMAGE)
1. Run `terraform get`.
1. Run `terraform init`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.
