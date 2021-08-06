# Access Extender, by Jo Anne Wilson
# a simple script to extend the access of employees with an expiration date by 60 days.

$user = read-host "Who would you like to extend? (username)"

set-adaccountexpiration $user -timespan 60.0:0

write-host "Done."