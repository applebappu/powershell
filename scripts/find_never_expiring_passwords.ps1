﻿search-adaccount -passwordneverexpires -usersonly | select name, samaccountname, distinguishedname | export-csv "c:\Users\jo\dev\reports\find_never_expiring_pwds.csv"