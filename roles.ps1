$all_OUs = get-adorganizationalunit -filter { name -like "*" }

foreach ($OU in $all_OUs) {
    $users = get-aduser -filter { enabled -eq $true } -Properties title -searchbase $OU
    $user_list = new-object System.Collections.Generic.List[System.Object]

    foreach ($user in $users) {
        $user_object = [pscustomobject]@{
            samaccountname = $user.samaccountname
            title = $user.title
            groups = (get-adprincipalgroupmembership $user | select -expandproperty name) -join ', '
            }
        $user_list.add($user_object)
    }

    $path = "C:\Users\jo\dev\scripts\role_search"
    $user_list | sort-object -property title | export-csv $path\$OU.csv
    get-childitem -path $path | where-object { $_.length -eq 0 } | remove-item
}