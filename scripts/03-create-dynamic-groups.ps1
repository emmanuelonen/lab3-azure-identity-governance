# ============================================================
# Lab 3 — Azure Identity & Access Management
# Script 03: Create Dynamic Security Groups and Verify Membership
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
# Dynamic groups evaluate membership rules against user attributes
# continuously. No manual group management. Users are added/removed
# automatically when their directory attributes change.
# Requires Microsoft Entra ID P2 licence.
# ============================================================

Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All", "GroupMember.Read.All"

# ── CREATE IT-STAFF DYNAMIC GROUP ────────────────────────────────────────────
# Rule: any user whose Department attribute equals "IT" is automatically a member.
# When a new IT employee is provisioned with Department = "IT", they inherit
# all IT access immediately — no administrator action required.
$DynamicRule = '(user.department -eq "IT")'

$ITStaffGroup = New-MgGroup `
    -DisplayName                 "IT-Staff" `
    -MailNickname                "ITStaff" `
    -SecurityEnabled             $true `
    -MailEnabled                 $false `
    -GroupTypes                  @("DynamicMembership") `
    -MembershipRule              $DynamicRule `
    -MembershipRuleProcessingState "On"

Write-Host "Dynamic group IT-Staff created" -ForegroundColor Green
Write-Host "Rule: $DynamicRule" -ForegroundColor Cyan

# ── CREATE ADDITIONAL DEPARTMENT GROUPS ──────────────────────────────────────
$Groups = @(
    @{ Name = "Finance-Staff"; Nick = "FinanceStaff"; Rule = '(user.department -eq "Finance")' },
    @{ Name = "HR-Staff";      Nick = "HRStaff";      Rule = '(user.department -eq "HR")'      },
    @{ Name = "Sales-Staff";   Nick = "SalesStaff";   Rule = '(user.department -eq "Sales")'   }
)

foreach ($g in $Groups) {
    New-MgGroup `
        -DisplayName                 $g.Name `
        -MailNickname                $g.Nick `
        -SecurityEnabled             $true `
        -MailEnabled                 $false `
        -GroupTypes                  @("DynamicMembership") `
        -MembershipRule              $g.Rule `
        -MembershipRuleProcessingState "On"

    Write-Host "Dynamic group $($g.Name) created — rule: $($g.Rule)" -ForegroundColor Green
}

# ── VERIFY DYNAMIC GROUP MEMBERSHIP ──────────────────────────────────────────
# Wait 30–60 seconds for Entra ID to evaluate the dynamic membership rules.
# Enterprise environments process dynamic membership changes on a cycle —
# not instant. In large tenants, processing can take up to 5 minutes.
Write-Host "`nWaiting 60 seconds for dynamic membership evaluation..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Check IT-Staff membership — john.doe (Department=IT) should appear automatically
$GroupId = (Get-MgGroup -Filter "displayName eq 'IT-Staff'").Id
Get-MgGroupMember -GroupId $GroupId |
    Select-Object Id, @{N="DisplayName";E={$_.AdditionalProperties.displayName}},
                      @{N="UPN";E={$_.AdditionalProperties.userPrincipalName}},
                      @{N="Department";E={$_.AdditionalProperties.department}}

Write-Host "`nExpected: john.doe appears automatically — no manual add performed" -ForegroundColor Cyan
Write-Host "Expected: jane.smith (Finance) does NOT appear in IT-Staff group" -ForegroundColor Cyan
