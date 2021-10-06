### script to make new accounts

## Initial user input
# get position, department, location
$User = read-host "Enter new user ID:"
$TicketNum = read-host "Enter the WHD ticket number"
$NewPass = read-host "Enter new password" -AsSecureString

## Active Directory
# place in correct OU
# First name, middle initial, last name, user logon name, @searhc.org
# create username according to rules
# error handling if username is taken
# generate random password (look at Chris' script)
set-adaccountpassword $User -reset -newpassword (ConvertTo-SecureString -AsPlainText $NewPass -Force)

## O365
# msonline and azure-ad connect
# licenses, depending on position

## WHD
# is it possible to do the ticket copy paste?