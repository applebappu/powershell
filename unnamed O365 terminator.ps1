# by Jo Anne Wilson, 2021.05.25
# strips O365 licenses from a list of users (note: non-functioning atm due to synching issues)

$targetlist = import-csv "C:\Users\jo\dev\scripts\Terminator\expiredusersterminated-05252021.csv"
$targets = $targetlist.samaccountname

connect-azuread
connect-msolservice

function Sync-ADDomain {
<# 
        .SYNOPSIS 
            Emulates the repadmin /syncall to force AD replication 
     
        .DESCRIPTION 
            Author:          Collin Chaffin 
            Description:    This function emulates the repadmin /syncall to 
                            force AD replication across all sites and domain 
                            controllers.  At the time I wrote this I could not 
                            find any example or suitable replacement to calling 
                            the repadmin binary 
     
        .EXAMPLE 
            C:\> Sync-ADDomain 
            Forcing Replication on WIN2008R2-DC1.lab.local 
            Forcing Replication on WIN2008R2-DC2.lab.local 
            Forcing Replication on WIN2008R2-DC3.lab.local 
     
        .EXAMPLE 
            C:\> Sync-ADDomain -WhatIf 
            What if: Performing operation "Forcing Replication" on Target "WIN2008R2-DC1.lab.local". 
            What if: Performing operation "Forcing Replication" on Target "WIN2008R2-DC2.lab.local". 
            What if: Performing operation "Forcing Replication" on Target "WIN2008R2-DC3.lab.local". 
    #>
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
  )
  begin
  {
    Write-Debug "Sync-ADDomain function started."

    try
    {
      # Set up the AD object and retrieve operator's current AD domain 
      $adDomain = $env:userdnsdomain
      Write-Debug "Detected operators AD domain as $($adDomain)"
      $objADContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext ("Domain",$adDomain)
      $domainControllers = [System.DirectoryServices.ActiveDirectory.DomainController]::FindAll($objADContext)
    }
    catch
    {
      #Throw terminating error 
      throw $("ERROR OCCURRED DETERMINING USERDNSDOMAIN AND RETRIEVING LIST OF DOMAIN CONTROLLERS " + $_.Exception.Message)
    }
  }
  process
  {

    try
    {
      # Cycle through all domain controllers emulating a repadmin /syncall 
      foreach ($domainController in $domainControllers)
      {
        if ($PSCmdlet.ShouldProcess($domainController,"Forcing Replication"))
        {
          Write-Host "Forcing Replication on $domainController" -ForegroundColor Cyan
          $domainController.SyncReplicaFromAllServers(([adsi]"").distinguishedName,'CrossSite')
        }
      }
    }
    catch
    {
      #Throw terminating error 
      throw $("ERROR OCCURRED FORCING DIRECTORY SYNCHRONIZATION " + $_.Exception.Message)
    }

  }
  end
  {
    Write-Debug "Sync-ADDomain function completed successfully."
  }
}

Sync-ADDomain

foreach ($target in $targets) {
    $userlist = Get-AzureADUser -ObjectID $target+'@searhc.org'
    $Skus = $userList | Select -ExpandProperty AssignedLicenses | Select SkuID
    if($userList.Count -ne 0) {
        if($Skus -is [array])
        {
            $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            for ($i=0; $i -lt $Skus.Count; $i++) {
                $Licenses.RemoveLicenses +=  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus[$i].SkuId -EQ).SkuID   
            }
            Set-AzureADUserLicense -ObjectId $Userlist -AssignedLicenses $licenses
        } else {
            $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            $licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus.SkuId -EQ).SkuID
            Set-AzureADUserLicense -ObjectId $Userlist -AssignedLicenses $licenses
        }
    }
}
