# script for Chaz
# this will help in your search by automating the process a little :D
# something to be aware of: at present, this script does NOT account for differences in title.  so, it will return supervisory users' groups mixed in
# with front-line workers, etc.  you could easily modify it to do so with some research, tho

# write a greeting to the screen
write-host "Welcome to AD Group Search!"

# set up variables
$selectedOU = read-host "Please enter the OU you wish to search."
$selectedjob = read-host "Please enter a general type of position or department (i.e. HIM, PFS, Nursing)"

# take those above inputs and search
# -searchbase flag delimits your search area
# -filter is how you ... filter results
# | pipes the output of a function in as input for the next
# "select name" ensures that we only get the names of each group back (otherwise, it's very messy)
# export-csv does exactly what it says on the tin
Get-ADUser -searchbase "OU=$selectedOU,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org" -filter 'Description -like "*HIM*"' | get-adprincipalgroupmembership | select name | export-csv Z:\himusergroups.csv

# this line grabs that exported CSV and outputs a sorted list of only unique groups
# not so useful for organizing it in the CSV itself, BUT if you want to expand this code, this kind of thing will come in handy
get-content Z:\himusergroups.csv | sort-object -unique