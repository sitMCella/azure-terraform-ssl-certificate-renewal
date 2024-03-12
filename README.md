# SSL Certificate Renewal

## Introduction

The SSL Certificate Renewal Terraform project defines an automation procedure for the renewal of the 
SSL Certificate of a web application hosted in one Azure App Service, and exposed via one Azure 
Application Gateway.

The web application used for this project is the dotnet Microsoft learn application https://github.com/MicrosoftDocs/mslearn-deploy-run-container-app-service.

The SSL Certificates are generated via Let's Encrypt. The Let's Encrypt challenges are 
stored in one Azure Storage Account. Let's Encrypt will verify the challenges using a static web 
application in the Storage Account.

One Azure DNS Zone is used to associate a subdomain of the custom domain with the web application.

The automation solution is implemented using a PowerShell script hosted in one Azure Function App. 

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

The properties correspond to: 
- tenant_id: Microsoft Entra tenant ID.
- subscription_id: Azure Subscription ID.
- client_id: client ID (application ID) of the App Registration.
- client_secret: secret of the App Registration.
- domain_name: name of the custom domain created in the domain registrar.
- email_address: email address used for creating the SSL certificate.
- pfx_password: password for the PFX SSL Certificate.

## Provision Solution

Enable the Terraform resources, following the sequence number of the comments in the Terraform code.

1. Configure the nameservers of the registered domain in the registrar portal with the nameservers defined by the Azure DNS Zone (Record name @, type NS).
2. Create a temporary record in the Azure DNS Zone in order to generate the initial SSL Certificate.
3. Configure the custom domain in the Storage Account after the temporary record has been created in the Azure DNS Zone.
4. Provision the Application Gateway after the initial SSL certificate has been added to the Key Vault using the function in the Azure Function App.
5. Create the final record in the Azure DNS Zone. Delete the temporary record from the Azure DNS Zone.

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
