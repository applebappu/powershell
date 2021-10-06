$users = get-aduser -filter * -properties passwordneverexpires, memberof
foreach ($user in $users) {
    set-aduser -identity $user -changepasswordatlogon $true -whatif
    set-aduser -identity $user -PasswordNeverExpires $false -whatif
    set-aduser -PasswordNeverExpires $false -whatif
}