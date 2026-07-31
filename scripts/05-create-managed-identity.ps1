# ============================================================
# Lab 3 — Azure Identity & Access Management
# Script 05: Provision Managed Identity, Assign RBAC & Test Token
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
# Managed Identities provide secretless service-to-service auth.
# Azure handles token issuance, rotation, and expiry automatically.
# Eliminates connection strings and credentials in application code.
# ============================================================

Connect-AzAccount

$ResourceGroupName = "rg-identity-lab"
$Location          = "eastus"
$IdentityName      = "app-identity"

# ── STEP 4.1: CREATE USER-ASSIGNED MANAGED IDENTITY ─────────────────────────
# User-assigned identities exist as independent Azure resources lifecycle-managed
# separately from compute workloads.
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $rg) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    Write-Host "Resource group $ResourceGroupName created" -ForegroundColor Green
}

$Identity = New-AzUserAssignedIdentity `
    -ResourceGroupName $ResourceGroupName `
    -Name              $IdentityName `
    -Location          $Location

Write-Host "User-assigned managed identity '$IdentityName' provisioned successfully" -ForegroundColor Green
Write-Host "Principal ID: $($Identity.PrincipalId)" -ForegroundColor Cyan
Write-Host "Client ID:    $($Identity.ClientId)" -ForegroundColor Cyan

# ── STEP 4.2: ASSIGN STORAGE BLOB DATA READER ROLE ────────────────────────────
# Find an existing storage account or create a dedicated test account
$Storage = Get-AzStorageAccount | Select-Object -First 1
if ($null -eq $Storage) {
    Write-Host "No existing storage account found. Creating new test storage account..." -ForegroundColor Yellow
    $Rand    = Get-Random -Minimum 1000 -Maximum 9999
    $Storage = New-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name              "stlab3identity$Rand" `
        -Location          $Location `
        -SkuName           "Standard_LRS"
}

New-AzRoleAssignment `
    -ObjectId           $Identity.PrincipalId `
    -RoleDefinitionName "Storage Blob Data Reader" `
    -Scope              $Storage.Id

Write-Host "Assigned 'Storage Blob Data Reader' role to managed identity at scope: $($Storage.Id)" -ForegroundColor Green

# ── STEP 4.3: TEST TOKEN ACQUISITION VIA IMDS (Run inside an Azure VM) ───────
# The snippet below demonstrates how a VM running under this Managed Identity
# queries the local Instance Metadata Service (IMDS) at link-local 169.254.169.254
# to acquire an OAuth 2.0 bearer token without storing secrets.
Write-Host "`n--- IMDS Token Acquisition PowerShell Command (Run on VM) ---" -ForegroundColor Yellow

$ImdsTestScript = @"
`$response = Invoke-RestMethod ``
    -Method Get ``
    -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/" ``
    -Headers @{Metadata = "true"}

`$accessToken = `$response.access_token

`$headers = @{Authorization = "Bearer `$accessToken"}
Invoke-RestMethod ``
    -Method Get ``
    -Uri "https://$($Storage.StorageAccountName).blob.core.windows.net/?comp=list" ``
    -Headers `$headers
"@

Write-Host $ImdsTestScript -ForegroundColor Gray
