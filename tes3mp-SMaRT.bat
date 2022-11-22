:: Feel free to cannibalize my awful code if you think you could use it in your own project. Or feel free to message
:: me about making you a specialized .bat This only took like a week to make. 
:: All ASCII art was generated at Lunicode.com

::====================================================Start=Batch====================================================::
@echo off
Title The Elder Scrolls 3 Multiplayer Server Monitor and Reboot Tool v 1.0
Color 0f
mode con: cols=120
Call :endlogo
SETLOCAL EnableExtensions
::===================================================Start=Preload===================================================::
:Top
IF NOT EXIST SMaRT-Settings.txt ( goto Setup)

for /F %%A in ("SMaRT-Settings.txt") do If %%~zA equ 0 del SMaRT-Settings.txt & goto Setup
ren SMaRT-Settings.txt SMaRT-Settings.bat
call SMaRT-Settings.bat Settings
ren SMaRT-Settings.bat SMaRT-Settings.txt
if [%FilePath%]==[ ] Goto Setup

call :FolderCration

if %CustomFPEnable%==1 set LocalPath=%FilePath%

if %CustomFPEnable%==0 set LocalPath=%cd%

color %bgc%%fnt%

set EXE=tes3mp-server.exe
Set /a BackupNumber=<backupcount.txt

start %LocalPath%\tes3mp-server.exe
echo ----------------------------------------------------
echo.
echo Start Log for Server on %date% at %time%
echo.
echo ----------------------------------------------------
echo.
IF %EnableLogging%==1 (
echo ----------------------------------------------------  >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo.                                                      >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo Start Log for Server on %date% at %time%              >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo.                                                      >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo ----------------------------------------------------  >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo.                                                      >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
)
::====================================================End=Preload====================================================::

::===================================================Start=Run=Code==================================================::
:StartCode

:: Month Check
IF %date:~4,2%== 1 (
set Month=Jan
) ELSE IF %date:~4,2%== 2 (
set Month=Feb
) ELSE IF %date:~4,2%== 3 (
set Month=Mar
) ELSE IF %date:~4,2%== 4 (
set Month=Apr
) ELSE IF %date:~4,2%== 5 (
set Month=May
) ELSE IF %date:~4,2%== 6 (
set Month=Jun
) ELSE IF %date:~4,2%== 7 (
set Month=Jul
) ELSE IF %date:~4,2%== 8 (
set Month=Aug
) ELSE IF %date:~4,2%== 9 (
set Month=Sep
) ELSE IF %date:~4,2%==10 (
set Month=Oct
) ELSE IF %date:~4,2%==11 (
set Month=Nov
) ELSE IF %date:~4,2%==12 (
set Month=Dec
)
:: Set the current date in day-month-year format
set /p mydate=%date:~7,2%-%Month%-%date:~10,4%

::Check if Server needs to restart.
goto restartcheck

:: Run Check if server exe is running.
:continue
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF %%x == %EXE% goto ProcessFound
goto ProcessNotFound

:: Success State, Server is running.
:ProcessFound
echo.
echo [%date% %time%] %EXE% is running
IF %EnableLogging%==1 (
echo.                                                      >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo [%date% %time%] %EXE% is running                      >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
)
goto Wait

:: Failure State, Server is not running, restart.
:ProcessNotFound
IF %EnableLogging%==1 (
echo.                                                      >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo [%date% %time%] ERROR : The Server may have crashed   >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo [%date% %time%] %EXE% is down                         >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
echo [%date% %time%] Starting %EXE%                        >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
)
echo.  
echo [%date% %time%] ERROR : The Server may have crashed
echo [%date% %time%] %EXE% is down 
echo [%date% %time%] Starting %EXE% 
start %LocalPath%\tes3mp-server.exe
goto Wait

::Wait ~10 seconds before looping again.
:Wait
ping localhost -n 10 -w 0 >nul
goto StartCode

:: Check if reboots are enabled.
:restartcheck
If /i %reboottoggle%==1 ( Goto checkboot)
If /i %reboottoggle%==0 ( Goto continue)

:: Check times for Reboot.
:checkboot
IF %Reboot-1%==1 (
	IF %time:~0,5% == %RebootTime1% ( set BackupTime=%RebootTime1Name% & goto Backup)
)
IF %Reboot-2%==1 (
	IF %time:~0,5% == %RebootTime2% ( set BackupTime=%RebootTime2Name% & goto Backup)
)
IF %Reboot-3%==1 (
	IF %time:~0,5% == %RebootTime3% ( set BackupTime=%RebootTime3Name% & goto Backup)
)
IF %Reboot-4%==1 (
	IF %time:~0,5% == %RebootTime4% ( set BackupTime=%RebootTime4Name% & goto Backup)
)
goto continue

:: Stops the server
:Backup
taskkill /f /im tes3mp-server.exe
IF %EnableLogging%==1 (                                                   		    >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
	echo [%date% %time%] Stopping server for %BackupTime%. reset.       >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
	echo.                                                      			>> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
	)
echo [%date% %time%] Stopping server for %BackupTime% reset.
echo.
:: check for Cell Backup
If %CellBackup%==0 ( goto SkipCellBackup)

:: Backup Cells listed in SMaRT-Settings.txt
:: Extra cells can be backed up by copying line 165, pasting it on line 164 and changing the 10's to 11 and so on.
:: If you add extra lines here, you must also add extra lines in the Settings sheet or the program could crash.
If Not %CellName1%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName1%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName1%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName2%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName2%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName2%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName3%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName3%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName3%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName4%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName4%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName4%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName5%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName5%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName5%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName6%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName6%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName6%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName7%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName7%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName7%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName8%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName8%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName8%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName9%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName9%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName9%-%mydate%-%time:~0,2%-%time:~3,2%.json")
If Not %CellName10%==0 ( copy /y "%LocalPath%\server\data\cell\%CellName10%.json" "%LocalPath%\SMaRT-Cell-Backup\%CellName10%-%mydate%-%time:~0,2%-%time:~3,2%.json")

Echo Backing up Cell Data.
Echo.
IF %EnableLogging%==1 (
	Echo Backing up Cell Data. >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
	Echo. 					   >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
)
:SkipCellBackup
:: Check if Character backup is enabled
If %BackupCharacter%==0 ( goto ResumeRestart)

:: Loop to separate Character Backups. Default is 5, but you could keep more by changing the LEQ # and Adding more folders
:Backup1
If %BackupNumber% LEQ 5 ( goto Backup2)
set /a BackupNumber=1
goto Backup1

:Backup2
Echo Backing up Player Data.
Echo.
IF %EnableLogging%==1 (
	Echo Backing up Player Data. >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
	Echo. 						 >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
)
copy /y "%LocalPath%\server\data\player\*.json" "%LocalPath%\SMaRT-Character-Backup\Backup%BackupNumber%"
echo Number is %BackupNumber%
set /a "BackupNumber=%BackupNumber%+1"
echo %BackupNumber% > backupcount.txt
goto ResumeRestart

:: restart Server
:ResumeRestart
ping localhost -n 30 -w 0 >nul
	IF %EnableLogging%==1 (
		echo [%date% %time%] Restarting server after %BackupTime% reset.  >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
		echo.                                                      		  >> %LocalPath%\SMaRT-Logs\tes3mp-SMaRT-Log%mydate%.txt
	)
echo [%date% %time%] Restarting server after %BackupTime% reset.
echo.
start %LocalPath%\tes3mp-server.exe
ping localhost -n 30 -w 0 >nul
goto continue
:: Return to top or Run Code


::====================================================End=Run=Code===================================================::

::====================================================Start=Setup====================================================::

:: No Documentation in this section, sorry, its all just questions, calling in code, and setting variables.
:Setup
Set CustomFPEnable=0 & Set FilePath=%cd% & Set bgc=0 & Set fnt=F & Set EnableLogging=0 & Set reboottoggle=0 & Set Reboot-1=0 & Set Reboot-2=0 & Set Reboot-3=0 & Set Reboot-4=0 & Set RebootTime1=0 & Set RebootTime2=0 & Set RebootTime3=0 & Set RebootTime4=0 & Set RebootTime1Name=0  & Set RebootTime2Name=0 & Set RebootTime3Name=0 & Set RebootTime4Name=0 & Set BackupCharacter=0 & Set CharBackupFreq=0 & Set CellBackup=0 & Set CellName1=0 & Set CellName2=0 & Set CellName3=0 & Set CellName4=0 & Set CellName5=0 & Set CellName6=0 & Set CellName7=0 & Set CellName8=0 & Set CellName9=0 & Set CellName10=0
:ColorSelect
color 0f
cls
call :logo
Echo Color choices from this list are not case sensitive.
echo.
echo    0 = Black       8 = Gray
echo    1 = Blue        9 = Light Blue
echo    2 = Green       A = Light Green
echo    3 = Aqua        B = Light Aqua
echo    4 = Red         C = Light Red
echo    5 = Purple      D = Light Purple
echo    6 = Yellow      E = Light Yellow
echo    7 = White       F = Bright White
echo.
Echo Please choose your background and Font colors
echo.
Echo Background
set /p bgc=
echo.
Echo Font
set /p fnt=
color %bgc%%fnt%
echo.
echo Confirm^? ^[Y/N^]
CHOICE /C YN /n
IF %ERRORLEVEL% EQU 2 goto ColorSelect
IF %ERRORLEVEL% EQU 1 goto FileLocation

:FileLocation
cls
call :logo
echo Is tes3mp-server.exe located in the current directory (%cd%)? [Y/N] [B]ack
CHOICE /C YNB /n
IF %ERRORLEVEL% EQU 3 goto ColorSelect
IF %ERRORLEVEL% EQU 2 goto ManualDirectory
IF %ERRORLEVEL% EQU 1 set FilePath=%cd% & goto EnableLogging

:ManualDirectory
Set CustomFPEnable=1 
cls
call :logo
echo Please point to the folder containing tes3mp-server.exe
set /p FilePath=
echo.
echo Confirm tes3mp-server.exe is located in %FilePath% [Y/N] [B]ack
CHOICE /C YNB /n
IF %ERRORLEVEL% EQU 3 goto FileLocation
IF %ERRORLEVEL% EQU 2 goto ManualDirectory
IF %ERRORLEVEL% EQU 1 goto EnableLogging

:EnableLogging
set EnableLogging=1
cls
call :logo
echo Logging will create a folder and a daily file logging server.
echo Would you like to enable the logging? [Y/N] [B]ack
CHOICE /C YNB /n
IF %ERRORLEVEL% EQU 3 goto FileLocation
IF %ERRORLEVEL% EQU 2 goto DisableLogging
IF %ERRORLEVEL% EQU 1 goto ToggleReboot

:DisableLogging
set EnableLogging=0

:ToggleReboot
set RebootToggle=1
Set Reboot-1=0
Set Reboot-2=0
Set Reboot-3=0
Set Reboot-4=0
cls
call :logo
echo Would you like to enable Automatic server reboots? [Y/N] [B]ack 
CHOICE /C YNB /n
IF %ERRORLEVEL% EQU 3 goto EnableLogging
IF %ERRORLEVEL% EQU 2 goto RebootWarning
IF %ERRORLEVEL% EQU 1 goto NumberOfBoots

:RebootWarning
set RebootToggle=0
cls
call :logo
echo Tes3mp 0.7.0 is known to encounter stack overflow errors if left running for too long.
echo Are you sure you want to disable automatic reboots? [Y/N]
CHOICE /C YN /n
IF %ERRORLEVEL% EQU 2 goto ToggleReboot
IF %ERRORLEVEL% EQU 1 goto ReviewSettings

:NumberOfBoots
set retrytime=0
cls
call :logo
echo How many times would you like the server to restart daily? [1-4] [B]ack
CHOICE /C 1234B /n
IF %ERRORLEVEL% EQU 5 goto ToggleReboot
IF %ERRORLEVEL% EQU 4 goto FourTimes
IF %ERRORLEVEL% EQU 3 goto ThreeTimes
IF %ERRORLEVEL% EQU 2 goto TwoTimes
IF %ERRORLEVEL% EQU 1 goto OneTimeWarning

:OneTimeWarning
echo.
echo Tes3mp 0.7.0 can encounter stack overflow errors if left for too long.
echo Are you sure you only want to restart the server once daily? [Y/N]
CHOICE /C YN /n
IF %ERRORLEVEL% EQU 2 goto NumberOfBoots
IF %ERRORLEVEL% EQU 1 goto OneBootTimeSchedule

:OneBootTimeSchedule
set retrytime=0
Set Reboot-1=1
cls
call :logo
echo What time would you like to reset the server? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto OneBootTimeSchedule)
call :CompileTimes
goto CharacterBackup

:TwoTimes
set retrytime=0
Set Reboot-1=1
cls
call :logo
echo What time would you like the first server reset to be? (Use letters)
call TimePicker
If %retrytime%==1 ( goto TwoTimes)
call CompileTimes
Set Reboot-2=1
:t22
set retrytime=0
cls
call :logo
echo What time would you like the Second server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto t22)
call :CompileTimes
goto CharacterBackup

:ThreeTimes
set retrytime=0
Set Reboot-1=1
cls
call :logo
echo What time would you like the First server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto ThreeTimes)
call :CompileTimes
Set Reboot-2=1
:t32
set retrytime=0
cls
call :logo
echo What time would you like the Second server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto t32)
call :CompileTimes
Set Reboot-3=1
:t33
set retrytime=0
cls
call :logo
echo What time would you like the Third server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto t33)
call :CompileTimes
goto CharacterBackup

:FourTimes
set retrytime=0
Set Reboot-1=1
cls
call :logo
echo What time would you like the First server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto FourTimes)
call :CompileTimes
Set Reboot-2=1
:t42
set retrytime=0
cls
call :logo
echo What time would you like the Second server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto t42)
call :CompileTimes
Set Reboot-3=1
:t43
set retrytime=0
cls
call :logo
echo What time would you like the Third server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto t43)
call :CompileTimes
Set Reboot-4=1
:t44
set retrytime=0
cls
call :logo
echo What time would you like the Fourth server reset to be? (Use letters)
call :TimePicker
If %retrytime%==1 ( goto t44)
call :CompileTimes
goto CharacterBackup

:CharacterBackup
cls
call :logo
echo Would you like to backup your player's character data? [Y/N] [B]ack
CHOICE /C ynb /n
IF %ERRORLEVEL% EQU 3 goto ToggleBoots
IF %ERRORLEVEL% EQU 2 ( Set BackupCharacter=0 & Set CharBackupFreq=0 & goto SaveSettings )
IF %ERRORLEVEL% EQU 1 ( Set BackupCharacter=1 & goto BackupFrequency )

:BackupFrequency
cls
call :logo
echo How often would you like to backup your player's character data? 
echo [1] Every Reboot [2] Every Other Reboot [3] Once a Day [B]ack
CHOICE /C 123b /n
IF %ERRORLEVEL% EQU 4 goto CharacterBackup
IF %ERRORLEVEL% EQU 3 CharBackupFreq=3
IF %ERRORLEVEL% EQU 2 CharBackupFreq=2
IF %ERRORLEVEL% EQU 1 CharBackupFreq=1

:ADVCellBackup
cls
call :logo
echo Would you like to enable Cell Backup? [Y/N] [B]ack
echo This will require editing the SMaRT-Settings.txt and is only recommended if you know your cell names,
echo and are worried about cell wipes due to installed scripts or griefing.
CHOICE /C ynb /n
IF %ERRORLEVEL% EQU 3 goto BackupFrequency
IF %ERRORLEVEL% EQU 2 set CellBackup=0
IF %ERRORLEVEL% EQU 1 Set CellBackup=1

Goto ReviewSettings
cls
call :logo
Echo Would you like to review your settings before creating SMaRT-Settings.txt? [Y/N]
CHOICE /C yn /n
IF %ERRORLEVEL% EQU 2 goto SkipReview
IF %ERRORLEVEL% EQU 1 goto ShowSettings

:ShowSettings
cls
call :logo
Call :SettingsOverview
echo.
echo Would you like to [C]onfirm these settings or [R]eturn to the beginning?
CHOICE /C cr /n
IF %ERRORLEVEL% EQU 2 goto ConfirmEraseSettings
IF %ERRORLEVEL% EQU 1 goto :SkipReview

:ConfirmEraseSettings
echo.
echo Are you sure you erase your current settings and start from the beginning? [Y/N]
CHOICE /C yn /n
IF %ERRORLEVEL% EQU 2 goto ShowSettings
IF %ERRORLEVEL% EQU 1 goto Settings

:SkipReview
Call :SaveSettings
Call :FolderCration
call :endlogo
pause
If %CellBackup%==1 ( goto CellBackupEnabledCloseForEditing )
goto Top

:CellBackupEnabledCloseForEditing
cls
call :logo
Echo The newly generated SMaRT-Settings.txt will now open, please follow the instructions at the bottom to add 
echo Cells to be backed up. Once you are finished please save the txt and then hit any key to continue.
echo.
pause
echo.
echo Opening SMaRT-Settings.txt
start SMaRT-Settings.txt
echo.
pause
goto top
::=====================================================End=Setup=====================================================::

::===============================================Start=Callable=Lines================================================::
:: Widget List if you wanna snag something

:: Time Compiler -------Line 516
:: Settings Sheet output Line 560
:: Time set widget ------Line 703
:: Folder Creator -------Line 744
:: ASCII header ---------Line 763
:: Splash Screen ASCII --Line 814

::==================================================================================================================::

:: Time Compiler ====

:: Check if time is at night to change to 24hr format or set 12 AM to 0 AM
:CompileTimes
if %RDay%==PM ( 
goto PMchange 
) else if %RDay%==AM ( 
goto AMchange 
)

:: Format time to inject properly into Settings
:SetTime
if %RDay%==PM (
if %Reboot-4%==1 ( Set RebootTime4Name=%RHour%%RDay% & Set RebootTime4=%R1Hour%:%RMinute% & EXIT /b)
if %Reboot-3%==1 ( Set RebootTime3Name=%RHour%%RDay% & Set RebootTime3=%R1Hour%:%RMinute% & EXIT /b)
if %Reboot-2%==1 ( Set RebootTime2Name=%RHour%%RDay% & Set RebootTime2=%R1Hour%:%RMinute% & EXIT /b)
if %Reboot-1%==1 ( Set RebootTime1Name=%RHour%%RDay% & Set RebootTime1=%R1Hour%:%RMinute% & EXIT /b)
) else if %RDay%==AM (
if %Reboot-4%==1 ( Set RebootTime4Name=%RHour%%RDay% & Set RebootTime4=%RHour%:%RMinute% & EXIT /b)
if %Reboot-3%==1 ( Set RebootTime3Name=%RHour%%RDay% & Set RebootTime3=%RHour%:%RMinute% & EXIT /b)
if %Reboot-2%==1 ( Set RebootTime2Name=%RHour%%RDay% & Set RebootTime2=%RHour%:%RMinute% & EXIT /b)
if %Reboot-1%==1 ( Set RebootTime1Name=%RHour%%RDay% & Set RebootTime1=%RHour%:%RMinute% & EXIT /b)
)
EXIT /b

:PMchange
	if %RHour%==12 ( set R1Hour=12)
	if %RHour%== 1 ( set R1Hour=13)
	if %RHour%== 2 ( set R1Hour=14)
	if %RHour%== 3 ( set R1Hour=15)
	if %RHour%== 4 ( set R1Hour=16)
	if %RHour%== 5 ( set R1Hour=17)
	if %RHour%== 6 ( set R1Hour=18)
	if %RHour%== 7 ( set R1Hour=19)
	if %RHour%== 8 ( set R1Hour=20)
	if %RHour%== 9 ( set R1Hour=21)
	if %RHour%==10 ( set R1Hour=22)
	if %RHour%==11 ( set R1Hour=23)
goto SetTime

:AMchange
	if %RHour%==12 ( set RHour= 0)
goto SetTime

:: Settings sheet Output
:SaveSettings
echo :Settings >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: >> SMaRT-Settings.txt
Echo ::                        _____          ________  _________   ________  ___     ______ _____                        :: >> SMaRT-Settings.txt
Echo ::                       ^|_   _^|        ^|____ ^|  ^\^/  ^|^| ___ ^\ ^/  ___^|  ^\^/  ^|     ^| ___ ^\_   _^|                       :: >> SMaRT-Settings.txt
Echo ::                         ^| ^| ___  ___     ^/ ^/ .  . ^|^| ^|_^/ ^/ ^\ `--.^| .  . ^| __ _^| ^|_^/ ^/ ^| ^|                         :: >> SMaRT-Settings.txt
Echo ::                         ^| ^|^/ _ ^\^/ __^|    ^\ ^\ ^|^\^/^| ^|^|  __^/   `--. ^\ ^|^\^/^| ^|^/ _` ^|    ^/  ^| ^|                         :: >> SMaRT-Settings.txt
Echo ::                         ^| ^|  __^/^\__ ^\.___^/ ^/ ^|  ^| ^|^| ^|     ^/^\__^/ ^/ ^|  ^| ^| (_^| ^| ^|^\ ^\  ^| ^|                         :: >> SMaRT-Settings.txt
Echo ::                         ^\_^/^\___^|^|___^/^\____^/^\_^|  ^|_^/^\_^|     ^\____^/^\_^|  ^|_^/^\__,_^\_^| ^\_^| ^\_^/                         :: >> SMaRT-Settings.txt
Echo ::                                       _____      _   _   _                                                        :: >> SMaRT-Settings.txt
Echo ::                                      ^/  ___^|    ^| ^| ^| ^| (_)                                                       :: >> SMaRT-Settings.txt
Echo ::                                      ^\ `--.  ___^| ^|_^| ^|_ _ _ __   __ _ ___                                        :: >> SMaRT-Settings.txt
Echo ::                                       `--. ^\^/ _ ^\ __^| __^| ^| '_ ^\ ^/ _` ^/ __^|                                       :: >> SMaRT-Settings.txt
Echo ::                                      ^/^\__^/ ^/  __^/ ^|_^| ^|_^| ^| ^| ^| ^| (_^| ^\__ ^\                                       :: >> SMaRT-Settings.txt
Echo ::                                      ^\____^/ ^\___^|^\__^|^\__^|_^|_^| ^|_^|^\__, ^|___^/                                       :: >> SMaRT-Settings.txt
Echo ::                                                                   __^/ ^|                                           :: >> SMaRT-Settings.txt
Echo ::                                                                  ^|___^/                                            :: >> SMaRT-Settings.txt
Echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
echo Set CustomFPEnable^=%CustomFPEnable%  >> SMaRT-Settings.txt
Echo :: FilePath is the location of the Tes3mp.exe This is very important as all files are relative to this file location. >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set FilePath^=%FilePath% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: bcg is Background color from the below chart >> SMaRT-Settings.txt
Echo :: fnt if the Font color from the below chart >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set bgc^=%bgc% >> SMaRT-Settings.txt
Echo Set fnt^=%fnt% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: ^+------------------------------------^+ >> SMaRT-Settings.txt
Echo :: ^|  0 ^= Black       8 ^= Gray          ^| >> SMaRT-Settings.txt
Echo :: ^|  1 ^= Blue        9 ^= Light Blue    ^| >> SMaRT-Settings.txt
Echo :: ^|  2 ^= Green       A ^= Light Green   ^| >> SMaRT-Settings.txt
Echo :: ^|  3 ^= Aqua        B ^= Light Aqua    ^| >> SMaRT-Settings.txt
Echo :: ^|  4 ^= Red         C ^= Light Red     ^| >> SMaRT-Settings.txt
Echo :: ^|  5 ^= Purple      D ^= Light Purple  ^| >> SMaRT-Settings.txt
Echo :: ^|  6 ^= Yellow      E ^= Light Yellow  ^| >> SMaRT-Settings.txt
Echo :: ^|  7 ^= White       F ^= Bright White  ^| >> SMaRT-Settings.txt
Echo :: ^+------------------------------------^+ >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: EnableLogging if set to 1 will create Log Files in Tes3mp\SMaRT-Log >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set EnableLogging^=%EnableLogging% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: reboottoggle will reboot the server at times listed below if set to 1 >> SMaRT-Settings.txt
Echo :: If set to 0 SMaRT will only restart after a server crash, but will not reboot to combat Stack Overflows >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set reboottoggle^=%reboottoggle% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: Setting Reboot-# to 1 will allow the server to automatically restart at least once at the specified time. >> SMaRT-Settings.txt
Echo :: If any of these are set to 0 the following fields of corresponding numbers can also be set to 0 or left blank >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set Reboot-1^=%Reboot-1% >> SMaRT-Settings.txt
Echo Set Reboot-2^=%Reboot-2% >> SMaRT-Settings.txt
Echo Set Reboot-3^=%Reboot-3% >> SMaRT-Settings.txt
Echo Set Reboot-4^=%Reboot-4% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: RebootTime^# is the Time at which the server will reboot.  >> SMaRT-Settings.txt
Echo :: This must be in 24 hour format and single digit times must have a leading space not a 0 >> SMaRT-Settings.txt
Echo :: Example " 9:30" is correct, "09:30" is incorrect, "9:30" is incorrect >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set RebootTime1^=%RebootTime1% >> SMaRT-Settings.txt
Echo Set RebootTime2^=%RebootTime2% >> SMaRT-Settings.txt
Echo Set RebootTime3^=%RebootTime3% >> SMaRT-Settings.txt
Echo Set RebootTime4^=%RebootTime4% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: RebootTime^#Name is the display name for the time and will show up in the SMaRT-Log >> SMaRT-Settings.txt
Echo :: This cannot have spaces or punctuation. It is recommended but not required that you use simple 12 hour format >> SMaRT-Settings.txt
Echo :: Example "2PM" is correct,"1400" Is also correct, "2.P.M" is incorrect, "2 PM" is incorrect >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set RebootTime1Name^=%RebootTime1Name%  >> SMaRT-Settings.txt
Echo Set RebootTime2Name^=%RebootTime2Name% >> SMaRT-Settings.txt
Echo Set RebootTime3Name^=%RebootTime3Name% >> SMaRT-Settings.txt
Echo Set RebootTime4Name^=%RebootTime4Name% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: BackupCharacter will copy all of the Tes3mp^\server^\data^\player^\^*.json files to the backup folder if set to 1 >> SMaRT-Settings.txt
Echo :: There are five backup folders and data will be saved in rotating order 1 -^> 2 -^> 3 -^> 4 -^> 5 -^> 1 ect. >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set BackupCharacter^=%BackupCharacter% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: Frequency of character backups can be >> SMaRT-Settings.txt
Echo :: Every time the server resets [1] >> SMaRT-Settings.txt
Echo :: Every other server reset [2] >> SMaRT-Settings.txt
Echo :: Once a day [3] >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set CharBackupFreq^=%CharBackupFreq% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: Setting CellBackup to 1 will enable the backing up of specific cells in the game. >> SMaRT-Settings.txt
Echo :: Cell Names are Located in %FilePate%^\server^\data^\cell and are .json files. >> SMaRT-Settings.txt
Echo :: You must have visited the cell in game for the [CellName].json to generate. >> SMaRT-Settings.txt
Echo :: Unless you a cell reset script like CCSuite or have troublesome players that could damage personal homes or Faction >> SMaRT-Settings.txt
Echo :: buildings and need consistent backups, it is recommended that you leave this set to 0 >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo Set CellBackup=%CellBackup% >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: There are only 10 Backupable cells by default in the SMaRT.bat, if you need to add more open .bat in a text editor >> SMaRT-Settings.txt
Echo :: of choice ^(Notepad++ is recommended^) and go to lines 155-165, and copy the code If Not CellName1^=^=0 ^(ECT.^) >> SMaRT-Settings.txt
Echo :: and paste it as many times as you need cells to back up. Then in this settings document add a corresponding number>> SMaRT-Settings.txt
Echo :: of Set Cellname[#]^=[CellName] under the rest.>> SMaRT-Settings.txt
Echo :: REMEMBER TO CHANGE THE #s IF YOU ADD MORE THAN 10 CELLs. Failure to do so can and probably will break SMaRT.bat>> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo :: Only include the name of the file, the .json should not be included in this section. >> SMaRT-Settings.txt
Echo :: Example "CellName1=Balmora Stronghold" is correct, "CellName1=Balmora Stronghold.json" is incorrect. >> SMaRT-Settings.txt
Echo. SMaRT-Settings.txt
Echo Set CellName1=0 >> SMaRT-Settings.txt
Echo Set CellName2=0 >> SMaRT-Settings.txt
Echo Set CellName3=0 >> SMaRT-Settings.txt
Echo Set CellName4=0 >> SMaRT-Settings.txt
Echo Set CellName5=0 >> SMaRT-Settings.txt
Echo Set CellName6=0 >> SMaRT-Settings.txt
Echo Set CellName7=0 >> SMaRT-Settings.txt
Echo Set CellName8=0 >> SMaRT-Settings.txt
Echo Set CellName9=0 >> SMaRT-Settings.txt
Echo Set CellName10=0 >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo ::^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=:: >> SMaRT-Settings.txt
Echo. >> SMaRT-Settings.txt
Echo exit /b >> SMaRT-Settings.txt
Exit /b

:: Widget to set your times 
:TimePicker
echo Hour (A) (B) (C) (D) (E) (F) (G) (H) (I) (J)  (K)  (l)
echo Hour [1] [2] [3] [4] [5] [6] [7] [8] [9] [10] [11] [12]
CHOICE /C abcdefghijkl /n
IF %ERRORLEVEL% EQU 12 set RHour=12
IF %ERRORLEVEL% EQU 11 set RHour=11
IF %ERRORLEVEL% EQU 10 set RHour=10
IF %ERRORLEVEL% EQU 9 set RHour= 9
IF %ERRORLEVEL% EQU 8 set RHour= 8
IF %ERRORLEVEL% EQU 7 set RHour= 7
IF %ERRORLEVEL% EQU 6 set RHour= 6
IF %ERRORLEVEL% EQU 5 set RHour= 5
IF %ERRORLEVEL% EQU 4 set RHour= 4
IF %ERRORLEVEL% EQU 3 set RHour= 3
IF %ERRORLEVEL% EQU 2 set RHour= 2
IF %ERRORLEVEL% EQU 1 set RHour= 1
echo.
echo Minute (A)  (B)  (C)  (D) 
echo Minute [00] [15] [30] [45]
CHOICE /C abcd /n
IF %ERRORLEVEL% EQU 4 set RMinute=:45
IF %ERRORLEVEL% EQU 3 set RMinute=:30
IF %ERRORLEVEL% EQU 2 set RMinute=:15
IF %ERRORLEVEL% EQU 1 set RMinute=:00
echo.
echo [A]M or [P]M?
CHOICE /c ap /n
IF %ERRORLEVEL% EQU 2 set RDay=PM
IF %ERRORLEVEL% EQU 1 set RDay=AM
echo.
echo Confirm you want to restart at %RHour%%RMinute%%RDay%? [Y/N]
CHOICE /c yn /n
IF %ERRORLEVEL% EQU 2 goto ExitPickerNo
IF %ERRORLEVEL% EQU 1 goto ExitPicker
:ExitPickerNo
set retrytime=1
exit /b
:ExitPicker
exit /b

:: Checks for folders and creates them if not present.
:FolderCration
IF %EnableLogging%==1 (
	IF NOT EXIST %FilePath%\SMaRT-Logs mkdir %FilePath%\SMaRT-Logs
)
IF %BackupCharacter%==1 (
	IF NOT EXIST %FilePath%\SMaRT-Character-Backup mkdir %FilePath%\SMaRT-Character-Backup
	IF NOT EXIST %FilePath%\SMaRT-Character-Backup\Backup1 mkdir %FilePath%\SMaRT-Character-Backup\Backup1
	IF NOT EXIST %FilePath%\SMaRT-Character-Backup\Backup2 mkdir %FilePath%\SMaRT-Character-Backup\Backup2
	IF NOT EXIST %FilePath%\SMaRT-Character-Backup\Backup3 mkdir %FilePath%\SMaRT-Character-Backup\Backup3
	IF NOT EXIST %FilePath%\SMaRT-Character-Backup\Backup4 mkdir %FilePath%\SMaRT-Character-Backup\Backup4
	IF NOT EXIST %FilePath%\SMaRT-Character-Backup\Backup5 mkdir %FilePath%\SMaRT-Character-Backup\Backup5
	IF NOT EXIST backupcount.txt echo 1 > backupcount.txt
)
IF %CellBackup%==1 (
	IF NOT EXIST %FilePath%\SMaRT-Cell-Backup mkdir %FilePath%\SMaRT-Cell-Backup	
)
Exit /b

:: Logo header to display on all settings pages
:logo
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo ::                         _____          ________  _________   _____                                                ::
echo ::                        ^|_   _^|        ^|____ ^|  \/  ^|^| ___ \ /  ___^|                                               ::
echo ::                          ^| ^| ___  ___     / / .  . ^|^| ^|_/ / \ `--.  ___ _ ____   _____ _ __                       ::
echo ::                          ^| ^|/ _ \/ __^|    \ \ ^|\/^| ^|^|  __/   `--. \/ _ \ '__\ \ / / _ \ '__^|                      ::
echo ::                          ^| ^|  __/\__ \.___/ / ^|  ^| ^|^| ^|     /\__/ /  __/ ^|   \ V /  __/ ^|                         ::
echo ::                          \_/\___^|^|___/\____/\_^|  ^|_/\_^|     \____/ \___^|_^|    \_/ \___^|_^|                         ::
echo ::             ___  ___            _ _                               _  ______     _                 _               ::
echo ::             ^|  \/  ^|           (_) ^|                             ^| ^| ^| ___ \   ^| ^|               ^| ^|              ::
echo ::             ^| .  . ^| ___  _ __  _^| ^|_ ___  _ __    __ _ _ __   __^| ^| ^| ^|_/ /___^| ^|__   ___   ___ ^| ^|_             ::
echo ::             ^| ^|\/^| ^|/ _ \^| '_ \^| ^| __/ _ \^| '__^|  / _` ^| '_ \ / _` ^| ^|    // _ \ '_ \ / _ \ / _ \^| __^|            ::
echo ::             ^| ^|  ^| ^| (_) ^| ^| ^| ^| ^| ^|^| (_) ^| ^|    ^| (_^| ^| ^| ^| ^| (_^| ^| ^| ^|\ \  __/ ^|_) ^| (_) ^| (_) ^| ^|_             ::
echo ::             \_^|  ^|_/\___/^|_^| ^|_^|_^|\__\___/^|_^|     \__,_^|_^| ^|_^|\__,_^| \_^| \_\___^|_.__/ \___/ \___/ \__^|            ::
echo ::                                      _____           _           _____   __                                       ::
echo ::                                     ^|_   _^|         ^| ^|         / __  \ /  ^|                                      ::
echo ::                                       ^| ^| ___   ___ ^| ^| __   __ `' / /' `^| ^|                                      ::
echo ::                                       ^| ^|/ _ \ / _ \^| ^| \ \ / /   / /    ^| ^|                                      ::
echo ::                                       ^| ^| (_) ^| (_) ^| ^|  \ V /  ./ /_____^| ^|_                                     ::
echo ::                                       \_/\___/ \___/^|_^|   \_/   \_____(_)___/                                     ::
echo ::                                                                                                                   ::
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.
exit /b

:: Review Settings
:SettingsOverview
Echo tes3mp server is located in %FilePath%
echo.
Echo Batch file color scheme is set to %bgc%%fnt%
echo.
If %EnableLogging%==1 ( echo Logging is Enabled.)
If %EnableLogging%==0 (echo Logging is Disabled.)
echo.
If %reboottoggle%==1 ( echo Server rebooting is Enabled.)
If %reboottoggle%==0 ( echo Server rebooting is Disabled.)
echo.
If %Reboot-1%==1 ( Echo First Reboot is at %RebootTime1% and is named %RebootTime1Name%.)
If %Reboot-2%==1 ( Echo Second Reboot is at %RebootTime2% and is named %RebootTime2Name%.)
If %Reboot-3%==1 ( Echo Third Reboot is at %RebootTime3% and is named %RebootTime3Name%.)
If %Reboot-4%==1 ( Echo Fourth Reboot is at %RebootTime4% and is named %RebootTime4Name%.)
echo.
If %BackupCharacter%==1 ( echo Character backup is Enabled.)
If %BackupCharacter%==0 ( echo Character backup is Disabled.)
echo.
If %BackupCharacter%==1 ( echo Character backup frequency is set to %CharBackupFreq%.)
echo.
If %CellBackup%==1 ( echo Advanced setting Cell Backup is Enabled, open SMaRT-Settings.txt to edit.)
exit /b

:: Splash logo
:endlogo
echo                                                 ..,:coddxxxkxxxdoc:,..                             & ping localhost -n 0 -w 0 >nul
echo                                           .':oxlxWMMMWMMMMMMMMWMMMWxlxo:'.                        & ping localhost -n 0 -w 0 >nul
echo                                        .;d0NWM0,,0MMMMMMMMMMMMMMMM0''0MWN0d;.                     & ping localhost -n 0 -w 0 >nul
echo                                      ,d0NMMMMWo  :XMWMMMMMMMMMMWMX:  oWMMMMN0d,                   & ping localhost -n 0 -w 0 >nul
echo                                   .:ONWMMMMMM0'   lNMMMMMMMMMMMMNl   '0MMMMMMMNk:.                & ping localhost -n 0 -w 0 >nul
echo                                 .;ONWWMMMMMWWo    .dWMMMMMMMMMMWd.    oWWMMMMMMWNO;.              & ping localhost -n 0 -w 0 >nul
echo                                'xNMMMMMMMMMMK,     .OMMMMMMMMMMk.     ,KMMMMMMMMMMNx'             & ping localhost -n 0 -w 0 >nul
echo                               ;0WWMMMMMMMMMWo       ,KMMMMMMMMK,       oWMMMMMMMMMWW0;            & ping localhost -n 0 -w 0 >nul
echo                             .lXMMMMMMMMMMMMK,        :O000K00O:        ;KMMMMMMMMMMMMXl.          & ping localhost -n 0 -w 0 >nul
echo                             lNMMMMMMMMMMMMWd          .......          .dWMMMMMMMMMMMMNl          & ping localhost -n 0 -w 0 >nul
echo                            :XMMMMMMMMMMMMMK;                            ;XMMMMMMMMMMMMMX:         & ping localhost -n 0 -w 0 >nul
echo                           '0MMMMMMMMMMMMMMd.   :dd:  .;;.     .ol,      .dMMMMMMMMMMMMMM0'        & ping localhost -n 0 -w 0 >nul
echo                           oWMWWMMMMMMMMMWK,    lNNl  .lXO'     .ol,.     ;KWMMMMMMMMMWWMWo        & ping localhost -n 0 -w 0 >nul
echo                          '0MMMMMMMMMMMMW0;             :K0;     .:NKx;    :0WMMMMMMMMMMMM0'       & ping localhost -n 0 -w 0 >nul
echo                          :NWWMMMMMMMMWNx.      :00:     ;KK:    ;0l;.      .xNWMWMMMMMMWWX:       & ping localhost -n 0 -w 0 >nul
echo                          cWMMMMMMMMMMKc        lddl      ,dk'  :o;.          cKMMMMMMMMMMWc       & ping localhost -n 0 -w 0 >nul
echo                          lWMMMMMMMMNk,                                        ,kNMMMMMMMMWl       & ping localhost -n 0 -w 0 >nul
echo                          cNMMMMMMMMNOdddddddddddddc.            .cdddddddddddddONMMMMMMWMNc       & ping localhost -n 0 -w 0 >nul
echo                          ,KWWMMMMMMMMMMMMMMMMMMMMMX:            ;XMMMMMMMMMMMMMMMMMMMMMWWK,       & ping localhost -n 0 -w 0 >nul
echo                          .kMMMMMMMMMMMMMMMMMMMMMMMMx.          .xMMMMMMMMMMMMMMMMMMMMMMMMk.       & ping localhost -n 0 -w 0 >nul
echo                           cNMMWMMMMMMMMMMMMMMMMMMMMX;          ;KMMMMMMMMMMMMMMMMMMMMMMMNc        & ping localhost -n 0 -w 0 >nul
echo                           .xWMMMMMMMMMMMMMMMMMMMMMWWd.         oWMMMMMMMMMMMMMMMMMMMMMMWx.        & ping localhost -n 0 -w 0 >nul
echo                            'OMMMMMMMMMMMMMMMMMMMMMMWK,        '0MMMMMMMMMMMMMMMMMMMMMMMO'         & ping localhost -n 0 -w 0 >nul
echo                             ,0MMMMMMMMMMMMMMMMMMMMMWWd.'lddl,.oWMMMMMMMMMMMMMMMMMMMMMM0,          & ping localhost -n 0 -w 0 >nul
echo                              'OWMMMMMMMMMMMMMMMMMMWKxcdNWMMMNxcd0NWMMMMMMMMMMMMMMMMMWO'           & ping localhost -n 0 -w 0 >nul
echo                               .dNWMMMMMMMMMWWWMXkl,.  lWMWMMWo  .,lkXWMWMWWMMMMMMMMNd.            & ping localhost -n 0 -w 0 >nul
echo                                 ;OWMMWMMMMMN0d:.      '0MMMMK,      .:oONWMMMMWMMWO;              & ping localhost -n 0 -w 0 >nul
echo                                  .c0WWMWKkl,.          oWMMMd.          'cxKWMWW0c.               & ping localhost -n 0 -w 0 >nul
echo                                    .cdo:.              ;KMMX;              .;odc.                 & ping localhost -n 0 -w 0 >nul
echo                                                        .xWWx.                                     & ping localhost -n 0 -w 0 >nul
echo                                                         :KKc                                      & ping localhost -n 0 -w 0 >nul
echo                                                         .cc.                                      & ping localhost -n 0 -w 0 >nul
echo. & ping localhost -n 0 -w 0 >nul
echo                                  DDDDDD.    OOOOO    SSSSS      FFFFFF & ping localhost -n 0 -w 0 >nul
echo                                  DDD  DDD  OOOOOOO  SSS         FF      oooo  xx   xx & ping localhost -n 0 -w 0 >nul
echo                                  DDD  DDD OOO   OOO  SSSSS  ^=^=^= FFFFF  oo  oo  xx xx & ping localhost -n 0 -w 0 >nul
echo                                  DDD  DDD  OOOOOOO      SSS     FF     oo  oo  xx xx & ping localhost -n 0 -w 0 >nul
echo                                  DDDDDD     OOOOO    SSSSS      FF      oooo  xx   xx & ping localhost -n 0 -w 0 >nul
echo. & ping localhost -n 0 -w 0 >nul
echo                                  Thank you for using Tes3mp SMaRT by DOS-Fox Designs & ping localhost -n 0 -w 0 >nul
echo. & ping localhost -n 0 -w 0 >nul
echo                       The Elder Scroll 3 Multiplayer Server Monitor and Reboot Tool version 2.1 & ping localhost -n 0 -w 0 >nul
echo                                                     October 2019 & ping localhost -n 0 -w 0 >nul
exit /b
::================================================End=Callable=Lines=================================================::

::=====================================================End=Batch=====================================================::
