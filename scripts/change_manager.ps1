$searchbase = "OU=Nuance - DAX,OU=Non SEARHC Employees,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"

get-aduser -searchbase $searchbase -filter * | set-aduser -manager chars