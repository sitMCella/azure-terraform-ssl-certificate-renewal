# SSL Certificate Renewal

## Introduction

The SSL Certificate Renewal Terraform project defines an automation procedure for the SSL Certificate 
of a web application hosted in one Azure App Service and exposed via one Azure Application Gateway.

The SSL Certificates are generated via Let's Encrypt and one Azure DNS Zone associates the custom domain 
with the web application.

The automation script is implemented in one Azure Function App, and 

## Requirements

1. Register a custom domain using a domain registrar, for example Namecheap or GoDaddy.
2. Create one Azure Principal Account (App Registration) in Microsoft Entra and generate the client secret.
3. Assign the RBAC role "Contributor" and "User Access Administrator" to the App Registration on the 
Subscription access control (IAM).

## Configuration

Create one file `secret/main.json` with the following content:
```
{
  "tenant_id": "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "client_id": "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "client_secret": "xxxxxxxxxxxxxxxxx"
}
```

The "tenant_id" property corresponds to the Microsoft Entra tenant ID. The "client_id" and "client_secret" 
properties correspond to the client ID and secret of the App Registration.

## Provision Solution

Execute the following Terrafom commands:

```$bash
terraform init -backend-config="secret/main.json" -reconfigure
terraform plan -var-file="secret/main.json"
terraform apply -var-file="secret/main.json" -auto-approve
```

## Development

### Format Terraform Code

```$bash
find . -not -path "*/.terraform/*" -type f -name '*.tf' -print | uniq | xargs -n1 terraform fmt
```