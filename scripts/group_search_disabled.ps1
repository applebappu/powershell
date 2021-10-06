# this script searches the Disabled Accounts OU and returns a list of names, usernames, managers, and group memberships.
# (the empty set indicates only Domain Users membership)
# by Jo Anne Wilson

$searchbase = "OU=Disabled Accounts,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"
get-aduser -searchbase $searchbase -filter * -properties memberof, manager | select name, samaccountname, manager, memberof