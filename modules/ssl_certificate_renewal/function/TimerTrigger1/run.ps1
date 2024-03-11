# Input bindings are passed in via param block.
param($Timer)

Import-Module Az.KeyVault
Import-Module Az.Storage
Import-Module ACME-PS

Get-Module

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

if (Test-Path "$env:TEMP\.key.xml") {
    Remove-Item -Path "$env:TEMP\.key.xml" -Force
}

if (Test-Path "$env:TEMP\Account.xml") {
    Remove-Item -Path "$env:TEMP\Account.xml" -Force
}

# Create a state object and save it to the harddrive.
$state = New-ACMEState -Path $env:TEMP
$serviceName = 'LetsEncrypt'

# Fetch the service directory and save it in the state.
Get-ACMEServiceDirectory $state -ServiceName $serviceName -PassThru;

# Get the first anti-replay nonce
New-ACMENonce $state;

# Create an account key. The state will make sure it's stored.
New-ACMEAccountKey $state -PassThru -Force;

# Register the account key with the acme service. The account key will automatically be read from the state.
New-ACMEAccount $state -EmailAddresses $env:EmailAddress -AcceptTOS;

# Load an state object to have service directory and account keys available
$state = Get-ACMEState -Path $env:TEMP;

# It might be neccessary to acquire a new nonce, so we'll just do it for the sake of the example.
New-ACMENonce $state -PassThru;

# Create the identifier for the DNS name.
$identifier = New-ACMEIdentifier $env:Domain;

# Create the order object at the ACME service.
$order = New-ACMEOrder $state -Identifiers $identifier;

# Fetch the authorizations for that order.
$authZ = Get-ACMEAuthorization -State $state -Order $order;

# Select a challenge to fullfill.
$challenge = Get-ACMEChallenge $state $authZ "http-01";

# Inspect the challenge data.
$challenge.Data;

# Create the file requested by the challenge.
$fileName = $env:TMP + '\' + $challenge.Token;
Set-Content -Path $fileName -Value $challenge.Data.Content -NoNewline;

# Connect to Azure using the Enterprise Application account.
$TenantId = $env:TenantId
$ApplicationId = $env:ApplicationId
$SecurePassword = $env:ClientSecret | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $TenantId

# Store the challenge token in the Storage Account.
$context = Get-AzSubscription -SubscriptionId $env:SubscriptionId
Set-AzContext $context
$blobName = ".well-known/acme-challenge/" + $challenge.Token
$storageAccount = Get-AzStorageAccount -ResourceGroupName $env:StorageResourceGroupName -Name $env:StorageName
$ctx = $storageAccount.Context
Set-AzStorageBlobContent -File $fileName -Container '$web' -Context $ctx -Blob $blobName

# Signal the ACME server that the challenge is ready.
$challenge | Complete-ACMEChallenge $state;

# Wait a little bit and update the order, until we see the states.
while($order.Status -notin ("ready","invalid")) {
    Start-Sleep -Seconds 10;
    $order | Update-ACMEOrder $state -PassThru;
}

# We should have a valid order now and should be able to complete it.
# Therefore we need a certificate key.
$certKey = New-ACMECertificateKey -Path "$env:TEMP\$domain.key.xml";

# Complete the order - this will issue a certificate signing request.
Complete-ACMEOrder $state -Order $order -CertificateKey $certKey;

# Wait until the ACME service provides the certificate url.
while(-not $order.CertificateUrl) {
    Start-Sleep -Seconds 15
    $order | Update-Order $state -PassThru
}

# As soon as the url shows up we can create the PFX.
$password = ConvertTo-SecureString -String "$env:PfxPassword" -Force -AsPlainText
Export-ACMECertificate $state -Order $order -CertificateKey $certKey -Path "$env:TEMP\$domain.pfx" -Password $password;

# Delete blob to check DNS.
Remove-AzStorageBlob -Container '$web' -Context $ctx -Blob $blobName

# Save the SSL Certificate in the Key Vault.
Import-AzKeyVaultCertificate -VaultName "$env:KeyVaultName" -Name "$env:KeyName" -FilePath "$env:TEMP\$domain.pfx" -Password $password
