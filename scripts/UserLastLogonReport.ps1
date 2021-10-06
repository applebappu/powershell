Import-Module ActiveDirectory

$date = get-date -format yyyyMMdd
 
$exportpath = "c:\temp\UserLoginReport-$date.csv"

function Get-ADUsersLastLogon()
{
  $searchbase = "OU=SEARHC Users,DC=intranet,DC=searhc,DC=org"
  
  $dcs = Get-ADDomainController -Filter {Name -like "*"}
  $users = Get-ADUser -Filter 'enabled -eq $true' -SearchBase $searchbase
  $time = 0
  $i = 0

  foreach($user in $users)
  {
    $i++
    foreach($dc in $dcs)
    { 
      $hostname = $dc.HostName
      $UserObject = Get-ADUser $user.SamAccountName -Properties EmployeeNumber,PasswordLastSet,Description,distinguishedname,PasswordNeverExpires,AccountExpirationDate,WhenCreated
      $currentUser = $UserObject | Get-ADObject -Server $hostname -Properties lastLogon, LastLogonTimestamp

      if($currentUser.LastLogon -gt $time) 
      {
        $time = $currentUser.LastLogon
      }
	  if($currentUser.LastLogonTimestamp -gt $time) 
      {
        $time = $currentUser.LastLogonTimestamp
      }
    }

    $dt = [DateTime]::FromFileTime($time)
    $row = $user.Name+","+$user.SamAccountName+","+$dt
	$Object = New-Object PSObject
	Add-Member -InputObject $Object -NotePropertyName "Name" -NotePropertyValue $user.Name
	Add-Member -InputObject $Object -NotePropertyName "SamAccountName" -NotePropertyValue $UserObject.SamAccountName
	Add-Member -InputObject $Object -NotePropertyName "TrueLastLogon" -NotePropertyValue $dt.ToString("yyyy-MM-dd HH:mm")
    Add-Member -InputObject $Object -NotePropertyName "Description" -NotePropertyValue $UserObject.Description
    Add-Member -InputObject $Object -NotePropertyName "DistinguishedName" -NotePropertyValue $UserObject.DistinguishedName
    Add-Member -InputObject $Object -NotePropertyName "EmployeeNumber" -NotePropertyValue $UserObject.EmployeeNumber
    Add-Member -InputObject $Object -NotePropertyName "PasswordLastSet" -NotePropertyValue $UserObject.PasswordLastSet
    Add-Member -InputObject $Object -NotePropertyName "PasswordNeverExpires" -NotePropertyValue $UserObject.PasswordNeverExpires
    Add-Member -InputObject $Object -NotePropertyName "AccountExpirationDate" -NotePropertyValue $UserObject.AccountExpirationDate
    Add-Member -InputObject $Object -NotePropertyName "WhenCreated" -NotePropertyValue $UserObject.WhenCreated
    	
	Write-Output $Object
    Write-Host "$($user.samaccountname)"
    Write-Host "$i of $($users.count)"
    $time = 0
  }
}
 
$UserReport = Get-ADUsersLastLogon
$UserReport | Export-Csv -Path $exportpath -NoTypeInformation