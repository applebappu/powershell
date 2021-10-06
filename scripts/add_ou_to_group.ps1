$searchbase1 = "OU=MEMC,OU=Out of State Nurses,OU=Clinical Temps,OU=Non SEARHC Employees,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"
$searchbase2 = "OU=Wrangell,OU=Out of State Nurses,OU=Clinical Temps,OU=Non SEARHC Employees,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"

get-aduser -searchbase $searchbase1 -filter * | foreach-object {add-adgroupmember -identity 'Pyxis ES Users' -members $_}
get-aduser -searchbase $searchbase2 -filter * | foreach-object {add-adgroupmember -identity 'Pyxis ES Users' -members $_}