#NoTrayIcon
#RequireAdmin
#include "..\variables.au3"
Local $Title = $Name & " v" & $Version & " Uninstaller"
#include <MsgBoxConstants.au3>
#include "_SelfDelete.au3"

If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, "Do you want to uninstall " & $Name & " v" & $Version & "?") <> $IDYES Then
    Exit
EndIf

If Not RunWait('schtasks /query /tn "' & $Name & '"', "", @SW_HIDE) Then
    If RunWait('schtasks /delete /tn "' & $Name & '" /f', "", @SW_HIDE) Then
        MsgBox($MB_ICONWARNING, $Title, "Failed to delete scheduled task!")
        Exit
    EndIf
EndIf

Local $delete = StringSplit("Windows Backup Pruning.exe", ",")
FileChangeDir(@ScriptDir)
For $i = 1 To $delete[0]
    If FileExists($delete[$i]) And Not FileDelete($delete[$i]) Then
        MsgBox($MB_ICONWARNING, $Title, "Failed to delete " & '"' & $delete[$i] & '"' & "!" & @CRLF & @CRLF & "Check to see if " & '"' & $delete[$i] & '"' & " is currently running and try again.")
        Exit
    EndIf
Next

If ( RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "DisplayName") <> "" Or RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "UninstallString") <> "" ) And Not RegDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, "Failed to delete uninstaller registry key!")
    Exit
EndIf

_SelfDelete(5, 1, 1)
If @error Then
    Exit MsgBox($MB_ICONWARNING, "_SelfDelete()", "The script must be a compiled exe to work correctly.")
EndIf