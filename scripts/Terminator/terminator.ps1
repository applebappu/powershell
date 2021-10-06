# THE TERMINATOR
# by Jo Anne Wilson
# last updated 2021.9.13

clear-host
write-host " _______  __   __  _______    _______  _______  ______    __   __  ___   __    _  _______  _______  _______  ______   "
write-host "|       ||  | |  ||       |  |       ||       ||    _ |  |  |_|  ||   | |  |  | ||   _   ||       ||       ||    _ |  "
write-host "|_     _||  |_|  ||    ___|  |_     _||    ___||   | ||  |       ||   | |   |_| ||  |_|  ||_     _||   _   ||   | ||  "
write-host "  |   |  |       ||   |___     |   |  |   |___ |   |_||_ |       ||   | |       ||       |  |   |  |  | |  ||   |_||_ "
write-host "  |   |  |       ||    ___|    |   |  |    ___||    __  ||       ||   | |  _    ||       |  |   |  |  |_|  ||    __  |"
write-host "  |   |  |   _   ||   |___     |   |  |   |___ |   |  | || ||_|| ||   | | | |   ||   _   |  |   |  |       ||   |  | |"
write-host "  |___|  |__| |__||_______|    |___|  |_______||___|  |_||_|   |_||___| |_|  |__||__| |__|  |___|  |_______||___|  |_|"
write-host " "
write-host "THE TERMINATOR will handle the AD termination process for you in one shot.  Use with caution!"

$sound = new-Object System.Media.SoundPlayer;
$sound.SoundLocation="\\sitfiles\it\ops\apps\Scripts\Terminator\T2.wav";
$sound.Play();

$Date = Get-Date -f "MMddyyyy"
$DescDate = get-date -f "MM-dd-yyyy"

$User = read-host "Enter user ID to TERMINATE"
$TicketNum = read-host "Enter the WHD ticket number"
write-host "`n"
write-host "Terminating..."

# logging
$logfile = "\\sitfiles\it\ops\apps\Scripts\Terminator\output\$User$Date.txt"

# Z drive archival variables
$HomeDir = "\\Sitka\Users\$User"
$AltHomeDir = "\\Sitfs01\Users\$User"
$Archive = "\\Sitnas5\HomeArchives\Sitka$User$Date.7z"
$AltArchive = "\\Sitnas5\HomeArchives\Sitfs01$User$Date.7z"
$SevenZip = "C:\Program Files\7-Zip\7z.exe"

# password scrambling using a word list
$WordList = Import-Csv "C:\Users\jo\dev\scripts\Terminator\WordList.csv"
$list1 = $WordList.List1
$list2 = $WordList.List2

# archive Z drive
If (Test-Path $HomeDir){
	Write-Host "$HomeDir will be archived to $Archive`n"
	(Start-Process -FilePath $SevenZip -Argumentlist "a -t7z $Archive $HomeDir" -Wait -Passthru)
    remove-item $HomeDir -recurse -force
    write-host "Z drive archived."
}
Elseif (Test-Path $AltHomeDir){
	Write-Host "$AltHomeDir will be archived to $AltArchive`n"
	(Start-Process -FilePath $SevenZip -Argumentlist "a -t7z $AltArchive $AltHomeDir" -Wait -Passthru)
    remove-item $AltHomeDir -recurse -force
    write-host "Z drive archived."
}
Else {
    Write-Host "User does not appear to have a Z drive."
}

# do password
$word1 = Get-Random -InputObject $list1 -Count 1
$word2 = Get-Random -InputObject $list2 -Count 1
$num = Get-Random -Maximum 99 -Minimum 10
$newpass = $word1+$word2+$num
set-adaccountpassword $User -reset -newpassword (ConvertTo-SecureString -asplaintext $newpass -force)
write-host "Password changed."

# hide from GAL
get-aduser $User | Set-ADObject -replace @{msExchHideFromAddressLists=$true}
write-host "Hidden from global address list."

# set mailnickname
get-aduser $User -properties mailnickname | set-aduser -replace @{mailnickname=$User}
write-host "Mailnickname property set."

# set primary group to domain users
$Group = get-adgroup "Domain Users" -properties @("primaryGroupToken")
get-aduser $User | set-aduser -replace @{primaryGroupID=$Group.primaryGroupToken}
write-host "Primary group is now Domain Users."

# remove other groups
get-aduser -identity $User -properties memberof | foreach-object {
    $_.memberof >> $logfile
    $_.memberof | remove-adgroupmember -members $_.distinguishedname -confirm:$false
}
write-host "All other group memberships removed."

# expiration date
clear-adaccountexpiration $User
write-host "Account expiration date cleared."

# write ticket number in notes field
$currentinfo = get-aduser -identity $User -properties info | select -ExpandProperty info
$newinfo = 'WHD '+$TicketNum+' - terminated'
$newinfo >> $logfile
$newnewinfo = "$currentinfo"+"`n"+"$newinfo"
set-aduser -identity $User -replace @{info=$newnewinfo}
write-host "Ticket number placed in notes field."

# clear contact info
set-aduser $User -clear telephonenumber, pager, ipphone, facsimileTelephoneNumber, mail
write-host "Phone numbers and email address cleared."

# description / job title
set-aduser $User -description $DescDate
write-host "Description replaced with date of termination."

disable-adaccount $User
write-host "Account disabled."

get-aduser $User | move-adobject -targetpath "OU=Disabled Accounts,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"
write-host "Object moved to Disabled Accounts OU."

write-host "...Hasta la vista, baby."
write-host "Don't forget to strip licenses in O365, check mobile devices in Azure, and disable TigerConnect / other apps!"