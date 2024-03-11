# SSL Certificate Renewal

## Introduction

The SSL Certificate Renewal Terraform project defines an automation procedure for the renewal of the 
SSL Certificate of a web application hosted in one Azure App Service and exposed via one Azure 
Application Gateway.

The web application is the dotnet Microsoft learn application https://github.com/MicrosoftDocs/mslearn-deploy-run-container-app-service

The SSL Certificates are generated via Let's Encrypt. One Azure DNS Zone is used to associate the 
custom domain with the web application.

The automation script is implemented using one Azure Function App. The Let's Encrypt challenges are 
stored in one Azure Storage Account. Let's Encrypt will verify the challenges using a static web 
application in the Storage Account.

## Requirements

1. Register one custom domain using a domain registrar, for example Namecheap or GoDaddy.
2. Create one Azure Principal Account (App Registration) in Microsoft Entra and generate the client secret.
3. Assign the RBAC roles "Contributor", "User Access Administrator", and "Key Vault Administrator" to the App Registration on the access 
control (IAM) of the Subscription.
4. Install Azure CLI in the local environment.

## Configuration

Create one file `secret/main.json` with the following content:
```
{
  "tenant_id": "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "subscription_id": "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "client_id": "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "client_secret": "xxxxxxxxxxxxxxxxx",
  "domain_name": "domain.xyz",
  "email_address": "account@email.com",
  "pfx_password": "pfxpa$$word"
}
```

The "tenant_id" property corresponds to the Microsoft Entra tenant ID. The "subscription_id" property 
correspond to the Azure Subscription ID. The "client_id" and "client_secret" properties correspond 
to the client ID and secret of the App Registration. The "domain_name" property corresponds to the 
name of the custom domain created in the domain registrar. The "email_address" property corresponds to 
the email address used for creating the SSL certificate. The "pfx_password" property corresponds to the 
password for the PFX SSL Certificate.

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
