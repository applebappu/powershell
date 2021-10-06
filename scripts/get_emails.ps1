$users = Import-Csv -Path C:\Users\jo\dev\scripts\doot.csv
foreach ($user in $users) {
    $thing = Get-ADUser -LDAPFilter "(&(GivenName=$($user.First))(Sn=$($user.Last)))" -Properties * | select samaccountname, emailaddress | export-csv -path C:\users\jo\dev\scripts\results.csv -append
}