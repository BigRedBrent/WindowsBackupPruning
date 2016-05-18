#include "variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
Global $Title = $Name & " v" & $Version & " Installer"
If _Singleton($Name & " Installer" & "346473046bWe46", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, $Name & " Installer" & " is already running!")
    Exit
EndIf
#include <WinAPIFiles.au3>
Local $BackupsToKeep, $Name = "Windows Backup Pruning"

Func SetBackupsToKeep($m)
    While 1
        Local $strNumber = InputBox($Title, @CRLF & "Number of backups to keep: ( " & $m & "+ )", $m, "", 320, 140)
        If @error <> 0 Then
            Exit
        EndIf
        Local $number = Floor(Number($strNumber))
        If $number >= $m Then
            $BackupsToKeep = $number
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, "You did not enter a valid number!")
    WEnd
EndFunc

Local $Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup\ScheduleParams\TargetDevice"
If @OSArch <> "X86" Then
    $Key = StringReplace($Key, "HKEY_LOCAL_MACHINE", "HKEY_LOCAL_MACHINE64")
EndIf

Local $BackupDir = RegRead($Key, "PresentableName")
If @error <> 0 Then
    MsgBox($MB_ICONWARNING, $Title, "Backup drive was not found!")
    Exit
EndIf

$BackupDir &= @ComputerName
If Not FileExists($BackupDir) Then
    MsgBox($MB_ICONWARNING, $Title, "Backup folder was not found!")
    Exit
EndIf

SetBackupsToKeep(2)

If Not DirCopy($Name, @ProgramFilesDir & "\" & $Name, 1) Then
    MsgBox($MB_ICONWARNING, $Title, "An error occurred while copying files to the programs folder!")
    Exit
EndIf

If Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "DisplayName", "REG_SZ", $Name & " v" & $Version) Or Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "UninstallString", "REG_SZ", '"' & @ProgramFilesDir & "\" & $Name & '\Uninstall.exe"') Then
    MsgBox($MB_ICONWARNING, $Title, "An error occurred while creating the uninstaller registry keys!")
    Exit
EndIf

Local $XMLFile = _WinAPI_GetTempFileName(@TempDir)

Local $XMLText = _
'<?xml version="1.0" encoding="UTF-16"?>' & @CRLF & _
'<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">' & @CRLF & _
'  <RegistrationInfo>' & @CRLF & _
'    <Author>SYSTEM</Author>' & @CRLF & _
'  </RegistrationInfo>' & @CRLF & _
'  <Triggers>' & @CRLF & _
'    <CalendarTrigger>' & @CRLF & _
'      <StartBoundary>2000-01-01T12:00:00</StartBoundary>' & @CRLF & _
'      <Enabled>true</Enabled>' & @CRLF & _
'      <ScheduleByDay>' & @CRLF & _
'        <DaysInterval>1</DaysInterval>' & @CRLF & _
'      </ScheduleByDay>' & @CRLF & _
'    </CalendarTrigger>' & @CRLF & _
'  </Triggers>' & @CRLF & _
'  <Principals>' & @CRLF & _
'    <Principal id="Author">' & @CRLF & _
'      <UserId>S-1-5-18</UserId>' & @CRLF & _
'      <RunLevel>HighestAvailable</RunLevel>' & @CRLF & _
'    </Principal>' & @CRLF & _
'  </Principals>' & @CRLF & _
'  <Settings>' & @CRLF & _
'    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>' & @CRLF & _
'    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>' & @CRLF & _
'    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>' & @CRLF & _
'    <AllowHardTerminate>true</AllowHardTerminate>' & @CRLF & _
'    <StartWhenAvailable>true</StartWhenAvailable>' & @CRLF & _
'    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>' & @CRLF & _
'    <IdleSettings>' & @CRLF & _
'      <StopOnIdleEnd>true</StopOnIdleEnd>' & @CRLF & _
'      <RestartOnIdle>false</RestartOnIdle>' & @CRLF & _
'    </IdleSettings>' & @CRLF & _
'    <AllowStartOnDemand>true</AllowStartOnDemand>' & @CRLF & _
'    <Enabled>true</Enabled>' & @CRLF & _
'    <Hidden>false</Hidden>' & @CRLF & _
'    <RunOnlyIfIdle>false</RunOnlyIfIdle>' & @CRLF & _
'    <WakeToRun>false</WakeToRun>' & @CRLF & _
'    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>' & @CRLF & _
'    <Priority>7</Priority>' & @CRLF & _
'  </Settings>' & @CRLF & _
'  <Actions Context="Author">' & @CRLF & _
'    <Exec>' & @CRLF & _
'      <Command>"' & @ProgramFilesDir & '\' & $Name & '\' & $Name & '.exe' & '"</Command>' & @CRLF & _
'      <Arguments>' & $BackupsToKeep & '</Arguments>' & @CRLF & _
'    </Exec>' & @CRLF & _
'  </Actions>' & @CRLF & _
'</Task>'

If Not FileWrite($XMLFile, $XMLText) Then
    MsgBox($MB_ICONWARNING, $Title, "An error occurred while writing the temporary XML file!")
    Exit
EndIf

If RunWait('schtasks /create /xml "' & $XMLFile & '" /tn "' & $Name & '" /f', "", @SW_HIDE) Then
    FileDelete($XMLFile)
    MsgBox($MB_ICONWARNING, $Title, "Failed to create scheduled task!")
    Exit
EndIf
FileDelete($XMLFile)

MsgBox(0, $Title, "Install successful." & @CRLF & @CRLF & "Number of backups to keep: " & $BackupsToKeep)