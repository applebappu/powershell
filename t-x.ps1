# T-X
# by Jo Anne Wilson, 2022.01.12
# Terminates a list of users from a .csv

$targetlist = import-csv "C:\Users\jo\dev\scripts\Terminator\Nologin_01.12.22.csv"
$targets = $targetlist.samaccountname
$date = get-date -f "MMddyyyy"
$descdate = get-date -f "MM-dd-yyyy"
$sevenzip = "C:\Program Files\7-Zip\7z.exe"
$wordlist = import-csv "C:\Users\jo\dev\scripts\Terminator\WordList.csv"
$list1 = $wordlist.List1
$list2 = $wordlist.List2
$group = get-adgroup "Domain Users" -properties @("primaryGroupToken")

foreach ($target in $targets) {
    $homedir = "\\Sitka\Users\$target"
    $althomedir = "\\Sitfs01\Users\$target"
    $archive = "\\Sitnas5\HomeArchives\Sitka$target$date.7z"
    $altarchive = "\\Sitnas5\HomeArchives\Sitfs01$target$date.7z"

    if (test-path $homedir){
	    (start-process -filepath $sevenzip -argumentlist "a -t7z $archive $homedir" -wait -passthru)
        remove-item $homedir -recurse -force
    }
    elseif (test-path $althomedir){
	    (start-process -FilePath $sevenzip -argumentlist "a -t7z $altarchive $althomedir" -wait -passthru)
        remove-item $althomedir -recurse -force
    }
    $word1 = get-random -inputobject $list1 -count 1
    $word2 = get-random -inputobject $list2 -count 1
    $num = get-random -minimum 10 -maximum 99
    $newpass = $word1+$word2+$num
    set-adaccountpassword $target -reset -newpassword (convertto-securestring -asplaintext $newpass -force) 
    get-aduser -identity $target | set-adobject -replace @{msexchhidefromaddresslists=$true}
    get-aduser -identity $target -properties mailnickname | set-aduser -replace @{mailnickname=$target}
    get-aduser -identity $target | set-aduser -replace @{primarygroupid=$group.primarygrouptoken}
    get-aduser -identity $target -properties memberof | foreach-object {
        $_.memberof | remove-adgroupmember -members $_.distinguishedname -confirm:$false
    }
    clear-adaccountexpiration $target
    set-aduser $target -clear telephonenumber, pager, ipphone, facsimileTelephoneNumber, mail
    set-aduser $target -description $descdate
    disable-adaccount $target
    get-aduser $target | move-adobject -targetpath "OU=Disabled Accounts,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"
}