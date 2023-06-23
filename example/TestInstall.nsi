; Include ReadCustomerData function
!include inc\ReadCustomerData.nsi

# set the name of the installer
Outfile "bin\TestInstall.exe"
 
# create a default section.
Section
 
# create a popup box, with an OK button and the text "Hello world!"
MessageBox MB_OK "Hello world!"
; Read Customer Data (e.g. "username;password")
Push "CUSTDATA:"
Call ReadCustomerData
Pop $1
StrCmp $1 "" 0 +3
MessageBox MB_OK "No data found"
Abort
MessageBox MB_OK "Customer data: [$1]"

SectionEnd