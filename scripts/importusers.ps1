param
(
    [string]$DomainName = "example.local"
)

# wait until we can access the AD. this is needed to prevent errors like:
#   Unable to find a default server with Active Directory Web Services running.
Write-Output "Waiting for the AD to become available... (Can take a long time)"
while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    } catch {
        Start-Sleep -Seconds 10
    }
}

# Add groups
Write-Output "Creating Groups..."
if (-Not(Get-ADGroup -F { Name -eq "alpha" }))
{
    NEW-ADGroup -name "alpha" -description "Alpha Users" -groupscope "Global"
}
if (-Not(Get-ADGroup -F { Name -eq "beta" }))
{
    NEW-ADGroup -name "beta"  -description "Beta Users"  -groupscope "Global"
}
if (-Not(Get-ADGroup -F { Name -eq "Gamma Nested" }))
{
    NEW-ADGroup -name "Gamma Nested"  -description "Gamma Users nested within Beta"  -groupscope "Global"
    Add-ADGroupMember "beta" "Gamma Nested"
}
if (-Not(Get-ADGroup -F { Name -eq "omega nested" }))
{
    NEW-ADGroup -name "omega nested"  -description "Omega Users nested within Gamma"  -groupscope "Global"
    Add-ADGroupMember "gamma nested" "omega nested"
}

# Import users from CSV (based on https://bit.ly/3as7DIH)
$ADUsers = Import-csv "c:\vagrant\scripts\users.csv"
Write-Output "Creating Users..."
$groupMembers = @{}
foreach ($User in $ADUsers)
{
    $Username = "$($User.first.SubString(0,1)).$($User.last)".toLower()

    #Check to see if the user already exists in AD
    if (Get-ADUser -F { SamAccountName -eq $Username })
    {
        Write-Warning "A user account with username $Username already exist in Active Directory."
    }
    else
    {
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@$domainName" `
            -Name "$( $User.first ) $( $User.last )" `
            -GivenName $User.first `
            -Surname $User.last `
            -Enabled $True `
            -DisplayName "$( $User.first ) $( $User.last )" `
            -AccountPassword (convertto-securestring "Foo_b_ar123!" -AsPlainText -Force) `
            -OfficePhone $User.phone `
            -City $User.city `
            -Company $User.company `
            -Department $User.department `
            -EmailAddress "$Username@example.com" `
            -HomePage $User.homepage `
            -MobilePhone $User.mobile `
            -PostalCode $User.postal_code `
            -StreetAddress $User.street `
            -Title $User.title `
            -PasswordNeverExpires $True

        foreach ($group in @($User.group1, $User.group2, $User.group3))
        {
            if ($group)
            {
                if (-not $groupMembers.ContainsKey($group)) { $groupMembers[$group] = @() }
                $groupMembers[$group] += $Username
            }
        }
    }
}

Write-Output "Assigning group memberships..."
foreach ($group in $groupMembers.Keys)
{
    Add-ADGroupMember -Identity $group -Members $groupMembers[$group]
}

# custom user with a very long name in UserPrincipalName
New-ADUser `
    -SamAccountName "longlong" `
    -UserPrincipalName "averylongusernamethatisverylong@$domainName" `
    -Name "Very Long" `
    -GivenName "Very" `
    -Surname "Long" `
    -Enabled $True `
    -DisplayName "Very Long" `
    -AccountPassword (convertto-securestring "Foo_b_ar123!" -AsPlainText -Force) `
    -EmailAddress "longlong@example.com" `
    -PasswordNeverExpires $True


# return success, even if there were warnings or errors above
exit 0
