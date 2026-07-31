# ============================================================
# Lab 3 — Azure Identity & Access Management
# Script 04: Configure RBAC — Built-in Assignment + Custom Role
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
# Azure RBAC enforces least-privilege on Azure resources.
# Built-in roles cover common scenarios. Custom roles fill gaps
# where built-in roles are either too permissive or too restrictive.
# ============================================================

Connect-AzAccount

# ── STEP 2.1: ASSIGN BUILT-IN READER ROLE ────────────────────────────────────
# Reader = read-only access to view all resources, no write or delete.
# Assigned at subscription scope — applies to all resource groups within it.
$UserUPN = "john.doe@eonenitgmail.onmicrosoft.com"
$User    = Get-AzADUser -UserPrincipalName $UserUPN
$SubId   = (Get-AzContext).Subscription.Id

New-AzRoleAssignment `
    -ObjectId           $User.Id `
    -RoleDefinitionName "Reader" `
    -Scope              "/subscriptions/$SubId"

Write-Host "Reader role assigned to john.doe at subscription scope" -ForegroundColor Green

# Verify the assignment
Get-AzRoleAssignment -ObjectId $User.Id |
    Select-Object DisplayName, RoleDefinitionName, Scope

# ── STEP 2.2: CREATE CUSTOM RBAC ROLE — VIRTUAL MACHINE OPERATOR ─────────────
# Contributor grants 100+ permissions.
# This custom role grants exactly 4 VM-specific permissions:
#   - Read VM properties
#   - Start a VM
#   - Restart a VM
#   - Stop/deallocate a VM
# No delete, no network modification, no storage access.
$role                  = New-Object -TypeName Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition
$role.Name             = "Virtual Machine Operator"
$role.Description      = "Can start, stop, and restart virtual machines without full Contributor rights."
$role.IsCustom         = $true
$role.AssignableScopes = @("/subscriptions/$SubId")

$permission         = New-Object -TypeName Microsoft.Azure.Commands.Resources.Models.Authorization.PSPermission
$permission.Actions = @(
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/deallocate/action"
)
$role.Permissions = @($permission)

New-AzRoleDefinition -Role $role

Write-Host "Custom role 'Virtual Machine Operator' created with 4 scoped permissions" -ForegroundColor Green
Write-Host "Permissions: read, start, restart, deallocate — NO delete, NO network, NO storage" -ForegroundColor Cyan

# Verify custom role creation
Get-AzRoleDefinition -Name "Virtual Machine Operator" |
    Select-Object Name, IsCustom, @{N='Actions';E={$_.Actions -join ", "}}
