###Send-EmailGroupManagers.ps1###
###Written by Chris Smith 3/27/2018###

# Get All distribution groups with managers Included #

$managedgroups = Get-adGroup -Filter {(ManagedBy -eq 'CN=Christopher Smith,OU=ISD,OU=Juneau,OU=SEARHC Users,DC=intranet,DC=searhc,DC=org') -and (GroupCategory -eq "Distribution")} -Properties *
				 #Get-ADGroup -LDAPFilter "(ManagedBy=*)" -Properties *

# Loop through each group, get manager and membership info, Send email to manager #

foreach ($group in $managedgroups) {

    #Get Members in Each Group
    $groupmembers = Get-ADGroupMember -Identity $group 
    
    #Get Managers Distinguished Name from ManagedBy attribute#
    $managerdn = Get-ADGroup $group -Properties ManagedBy | select ManagedBy -ExpandProperty ManagedBy 

    #Get Managers AD account
    $manager = get-aduser -Filter {DistinguishedName -eq $managerdn} -Properties DisplayName,EmailAddress

    #Clean Up Variables for Email#
    $groupname = $group.Name
    $managername = $manager.DisplayName
    $groupmembernames = $groupmembers.name -join "<br>" | Out-String

    
    #Email Options
    $options = @{
        'SmtpServer' = "smtp.intranet.searhc.org" 
        'To' = $manager.EmailAddress
        'From' = "helpdesk@searhc.org" 
        'Subject' = "Email Group Audit for group: $groupname" 
        'Body' = "
        <br>
Dear $managername,<br><br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;You are receiving this email message because you are listed as the manager of the email group <b>$groupname</b>.  Please verify the status of this group and its members. If the group is no longer used, or changes need to be made, please email helpdesk@searhc.org or reply to this email.<br>
<br>
The current group members of <b>$groupname</b> are:<br><br>

$groupmembernames
<br><br>
Thank you,<br>
SEARHC IT
"
        }       
    
#Send Email

    Send-MailMessage -BodyAsHtml @options 

   
}

