# removes manager field from a given OU (in this case, Disabled Accounts)
# by Jo Anne Wilson

$searchbase = "OU=Disabled Accounts,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"

get-aduser -searchbase $searchbase -filter * | set-aduser -clear manager