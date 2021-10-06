# THE T-1000
# a faster, slicker version of The Terminator, that searches for expired users and terminates their AD attributes.
# updated 2021.9.13

$date = get-date -f "MMddyyyy"
$descdate = get-date -f "MM-dd-yyyy"

$johnconnors = Search-ADAccount -AccountExpired
$johnconnors | select name, samaccountname | export-csv "\\sitfiles\it\ops\apps\scripts\Terminator\output\expiredusersterminated-$date.csv"

$SevenZip = "C:\Program Files\7-Zip\7z.exe"

$WordList = Import-Csv "\\sitfiles\it\ops\apps\scripts\Terminator\WordList.csv"
$list1 = $WordList.List1
$list2 = $WordList.List2

foreach ($john in $johnconnors) {
    $HomeDir = "\\Sitka\Users\$john"
    $AltHomeDir = "\\Sitfs01\Users\$john"
    $Archive = "\\Sitnas5\HomeArchives\Sitka$john$date.7z"
    $AltArchive = "\\Sitnas5\HomeArchives\Sitfs01$john$date.7z"
    If (Test-Path $HomeDir){
	    (Start-Process -FilePath $SevenZip -Argumentlist "a -t7z $Archive $HomeDir" -Wait -Passthru)
        remove-item $HomeDir -recurse -force
    }
    If (Test-Path $AltHomeDir){
	    (Start-Process -FilePath $SevenZip -Argumentlist "a -t7z $AltArchive $AltHomeDir" -Wait -Passthru)
        remove-item $AltHomeDir -Recurse -force 
    }

    get-aduser $john | Set-ADObject -replace @{msExchHideFromAddressLists=$true}

    get-aduser $john -properties mailnickname | set-aduser -replace @{mailnickname=$john.SamAccountName}

    $group = get-adgroup "Domain Users" -properties @("primaryGroupToken")
    get-aduser $john | set-aduser -replace @{primaryGroupID=$group.primaryGroupToken}

    get-aduser -identity $john -properties memberof | foreach-object {
      $_.memberof | remove-adgroupmember -members $_.distinguishedname -confirm:$false

    }

    clear-adaccountexpiration $john

	$word1 = Get-Random -InputObject $list1 -Count 1
	$word2 = Get-Random -InputObject $list2 -Count 1
	$num = Get-Random -Maximum 99 -Minimum 10
	$newpass = $word1+$word2+$num
    set-adaccountpassword $john -reset -newpassword (ConvertTo-SecureString -asplaintext $newpass -force)

    set-aduser $john -clear telephonenumber, pager, ipphone, facsimiletelephonenumber, mail, manager

    set-aduser $john -description $descdate

    disable-adaccount $john

    get-aduser $john | move-adobject -targetpath "OU=Disabled Accounts,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"
}