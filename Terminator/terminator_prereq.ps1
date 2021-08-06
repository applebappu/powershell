# this little script will install the necessary prerequesites to run THE TERMINATOR. run as admin

install-packageprovider nuget -force
install-module powershellget -force
update-module powershellget
install-module azuread
install-module msonline
exit