#NoTrayIcon
#include <Misc.au3>
#include <MsgBoxConstants.au3>
Local $Title = "Windows Backup Pruning"
_Singleton($Title & "RBFTdi8Qb4fn")

Local $BackupsToKeep = 2

#include <File.au3>
#include <Array.au3>

If $CmdLine[0] And $CmdLine[1] And Number($CmdLine[1]) >= 2 Then
    $BackupsToKeep = Number($CmdLine[1])
EndIf
$BackupsToKeep = Floor($BackupsToKeep)

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

Local $FolderList = _FileListToArray($BackupDir, "Backup Set ????-??-?? ??????", 2)
If @error <> 0 Then
    Exit
EndIf

If $BackupsToKeep >= 2 And $FolderList[0] > $BackupsToKeep Then
    _ArraySort($FolderList)
    For $i = 1 To $FolderList[0] - $BackupsToKeep
        DirRemove($BackupDir & "\" & $FolderList[$i], 1)
    Next
EndIf