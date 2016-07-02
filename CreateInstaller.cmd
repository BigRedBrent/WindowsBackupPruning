@ECHO OFF
SET VERSION=5.3
SET NAME=Windows Backup Pruning
SET INSTALLER=WindowsBackupPruning
SET EXE=%NAME%,Uninstall

(
    ECHO #include-once
    ECHO Global $Name = "%NAME%"
    ECHO Global $Version = "%VERSION%"
) > .\Install\variables.au3

FOR %%i IN ("%EXE:,=" "%") DO "%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\%%~i.au3" /out ".\Install\%NAME%\%%~i.exe" /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in .\Install\setup.au3 /out .\Install\setup.exe /nopack /x86

DEL %INSTALLER%.exe
"%ProgramFiles%\7-Zip\7z.exe" a Installer.7z .\Install\* -r -x!Thumbs.db -x!ehthumbs.db -x!Desktop.ini -x!*.au3

(
    ECHO ^;^!@Install@!UTF-8^!
    ECHO Title="%NAME% v%VERSION% Installer"
    ECHO BeginPrompt="Do you want to install %NAME% v%VERSION%?"
    ECHO RunProgram="setup.exe"
    ECHO ^;^!@InstallEnd@^!
) > config.txt

COPY /b 7zS.sfx + config.txt + Installer.7z %INSTALLER%.exe

DEL Installer.7z
DEL config.txt
DEL .\Install\setup.exe
FOR %%i IN ("%EXE:,=" "%") DO DEL ".\Install\%NAME%\%%~i.exe"
PAUSE