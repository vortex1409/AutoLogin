# AutoLogin
Script used to enable automatic login to a specific user account (domain or local) on Microsoft Windows using the command line.

## Usage
Using the cscript engine, you can provide the following switches:
+ /u:USERNAME
+ /p:PASSWORD
+ /d:DOMAIN
+ /c to clear all autologins
+ /r automatically reboot after a change is made
+ /? or ?h help screen

If you accidentally use wscript, the script will **quietly** restart itself using cscript.

## Return Codes
+ 0 is success, everything else is failure
+ 1 Missing USERNAME
+ 2 Missing PASSWORD
+ 4 Error while changing the registry
