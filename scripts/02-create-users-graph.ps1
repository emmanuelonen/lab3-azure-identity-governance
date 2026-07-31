# ============================================================
# Lab 3 — Azure Identity & Access Management
# Script 02: Create Enterprise Users via Microsoft Graph SDK
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
# Uses the Microsoft Graph PowerShell SDK — the production-standard
# method for identity provisioning at scale. GUI-based creation does
# not scale across enterprise environments and introduces human error.
# ============================================================

# Connect to Microsoft Graph with required scopes
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"

# Verify the connection and tenant context
Get-MgContext | Select-Object TenantId, Account, Scopes

# ── CREATE USER — john.doe ───────────────────────────────────────────────────
# Department and JobTitle attributes are critical — they drive dynamic
# group membership rules and ABAC policy assignment downstream.
$PasswordProfile = @{
    Password                      = "SecureLabPassword123!"
    ForceChangePasswordNextSignIn = $true
}

New-MgUser `
    -DisplayName       "John Doe" `
    -UserPrincipalName "john.doe@eonenitgmail.onmicrosoft.com" `
    -MailNickname      "john.doe" `
    -PasswordProfile   $PasswordProfile `
    -AccountEnabled    $true `
    -Department        "IT" `
    -JobTitle          "Senior Cloud Engineer"

Write-Host "User john.doe provisioned with IT department attribute" -ForegroundColor Green

# ── VERIFY USER CREATION ─────────────────────────────────────────────────────
Get-MgUser -Filter "UserPrincipalName eq 'john.doe@eonenitgmail.onmicrosoft.com'" |
    Select-Object DisplayName, UserPrincipalName, Department, JobTitle, AccountEnabled

# ── NOTE ON HTTP 400 ERROR ───────────────────────────────────────────────────
# Running this script a second time against an existing UPN returns:
#   HTTP 400 / Request_BadRequest — A User with the specified UserPrincipalName already exists
# This confirms Microsoft Entra ID strictly enforces unique object
# constraints at the tenant directory layer via REST API error handling.
# In production, check for existing UPN before provisioning.

# ── ADDITIONAL TEST USERS (for group membership testing) ─────────────────────
# Create a Finance user — will NOT match IT-Staff dynamic group
$PasswordProfile2 = @{
    Password                      = "SecureLabPassword123!"
    ForceChangePasswordNextSignIn = $true
}

New-MgUser `
    -DisplayName       "Jane Smith" `
    -UserPrincipalName "jane.smith@eonenitgmail.onmicrosoft.com" `
    -MailNickname      "jane.smith" `
    -PasswordProfile   $PasswordProfile2 `
    -AccountEnabled    $true `
    -Department        "Finance" `
    -JobTitle          "Finance Analyst"

Write-Host "User jane.smith provisioned with Finance department — will NOT match IT-Staff group" -ForegroundColor Yellow
