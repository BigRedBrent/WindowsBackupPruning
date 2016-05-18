RELEASE NOTES
=============

5.2
- Consolidated installer into one file.

5.1
- Added uninstaller.

5.0
- Made script work the same way for all versions of windows.

4.1
- Simplified the way the temporary XML file is created.

4.0
- Will now use the "wbadmin delete systemstatebackup" command for versions of windows greater than Windows 7.

3.1
- Will now properly exit on errors when trying to install the Scheduled Task.

3.0
- Added confirmation that the Scheduled Task was created successfully.

2.2
- Now "Create Scheduled Task" installs the exe file into the Program Files folder.

2.1
- Added check for backup folder when creating the scheduled task.

2.0
- Added script to create scheduled task.
- Restricted minimum backups to keep at least 2.

1.3
- Changed folder name pattern matching to be much more strict.

1.2
- Added double check to make sure that at least one backup will not be deleted.

1.1
- Changed the way 64 bit operating systems are detected.

1.0
- First release.