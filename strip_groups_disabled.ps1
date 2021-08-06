# this script goes through the Disabled OU, reassigns primary groups to Domain Users, and removes all other group memberships.
# by Jo Anne Wilson

$searchbase = "OU=Disabled Accounts,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"
$group = get-adgroup "Domain Users" -properties @("primaryGroupToken")

get-aduser -searchbase $searchbase -filter * -properties memberof | set-aduser -replace @{primaryGroupID=$group.primaryGroupToken} | foreach-object {
  $_.memberof | remove-adgroupmember -members $_.distinguishedname -confirm:$false
  
}