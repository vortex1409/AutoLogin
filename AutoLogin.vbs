' Will auto login / clear auto login
' /u:USERNAME /p:PASSWORD /d:DOMAIN
' Use /c to clear autologin
' 0 is success, everything else is failure
' 1 Missing USERNAME
' 2 Missing PASSWORD
' 3 Wrong Script Engine
' 4 Error while changing the registry

Set wshShell = CreateObject( "WScript.Shell" )
If Not LCase( Right( WScript.FullName, 12 ) ) = "\cscript.exe" Then
	WScript.Echo "Starting with CSCRIPT instead."

	DIM argsConc

	FOR EACH arg in WScript.Arguments.Named
		arg = " /" & arg
		argsConc = argsConc & arg
	NEXT

	WScript.Quit wshShell.Run("cscript.exe " & chr(34) & WScript.ScriptFullName & chr(34) & argsConc)
END IF

WScript.Echo "AutoLogin V2.2 (c) Falko Retter, 2015 - 2016"

Set args = Wscript.Arguments.Named

'Setup editing the registry.
HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."

Set objRegistry  = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")
strPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

' See if we're just outputting help
IF args.Exists("h") OR args.Exists("?") THEN
	WScript.Echo ""
	WScript.Echo "/u:<username> /p:<password> - autologin to a domain user"
	WScript.Echo "/d:<domain> - Domain to login to. Ommit for local user account."
	WScript.Echo "/c - clear all autologins (when used with /d: set default domain)"
	WScript.Echo "/r - automatically reboot after a change is made"
	WScript.Echo "/h or /? - show these hints"
	WScript.Quit 2
END IF

' Handle domain accounts (If no domain is set, use the computer name)
strDomain = wshShell.ExpandEnvironmentStrings( "%COMPUTERNAME%" )
IF args.Exists("d") Then
	strDomain = args("d")
END IF

' Clear Autologin, then quit or restart
IF args.Exists("c") THEN
	WScript.Echo "Clearing autologin."
	objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strPath, "DefaultUserName", ""
	objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strPath, "DefaultPassword", ""
	objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strPath, "DefaultDomainName", strDomain
	objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strPath, "AutoAdminLogon", "0"
	CALL CheckIfRestart
END IF

' Quit when there's crucial switches missing
IF NOT args.Exists("u") THEN
	WScript.Echo "Missing username"
	WScript.Quit 1
END IF

IF NOT args.Exists("p") THEN
	WScript.Echo "Missing password"
	WScript.Quit 2
END IF

WScript.Echo "Enabling autologin for " & strDomain & "\" & args("u")

' Set registry values
checkReturn "CreateKeyName", objRegistry.CreateKey(HKEY_LOCAL_MACHINE, strPath)
checkReturn "SetName", objRegistry.SetStringValue(HKEY_LOCAL_MACHINE, strPath, "DefaultUserName", args("u"))

checkReturn "CreateDefaultPass", objRegistry.CreateKey(HKEY_LOCAL_MACHINE, strPath)
checkReturn "SetDefaultPass", objRegistry.SetStringValue(HKEY_LOCAL_MACHINE, strPath, "DefaultPassword", args("p"))

checkReturn "CreateDefaultDomain", objRegistry.CreateKey(HKEY_LOCAL_MACHINE, strPath)
checkReturn "SetDefaultDomain", objRegistry.SetStringValue (HKEY_LOCAL_MACHINE, strPath, "DefaultDomainName", strDomain)

checkReturn "SetAutoLogon", objRegistry.SetStringValue (HKEY_LOCAL_MACHINE, strPath, "AutoAdminLogon", "1")
CALL CheckIfRestart

' ///////////////////// SUBS ////////////////////////////

SUB CheckIfRestart
	' Do not restart
	IF NOT args.Exists("r") THEN
		WScript.Echo "Not restarting"
		WScript.Quit 0
	END IF

	WScript.Echo "Restarting"
	wshShell.run "C:\Windows\System32\shutdown.exe /r /t 0"

	Wscript.Quit 0
END SUB

SUB checkReturn(strStep, intReturn)
	If NOT (intReturn = 0) OR NOT (Err.Number = 0) Then
		Wscript.Echo "Failed on step " & strStep
		Wscript.Echo "Error " & Err.Number
		Wscript.Echo "Return " & intReturn
		WScript.Quit 4
	End If
END SUB
