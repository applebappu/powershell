$users = Import-Csv -Path C:\Users\jo\dev\scripts\doot.csv
foreach ($user in $users) {
    Get-ADUser -identity $user -Properties * | select samaccountname, emailaddress | export-csv -path C:\users\jo\dev\scripts\results.csv -append
}