@echo off
@echo Running config batch

:: Run Mode, set runMode=Pilot for debugging with verbose logs or else set runMode=Deployment
set runMode=Deployment
set runMode=%runMode:"=%

:: File share to store telemetry logs
set logPath=\\set\path\here
set logPath=%logPath:"=%

:: Commercial ID provided to you
:: Go to your OMS workspace navigate to path \Settings\Connected Sources\Windows Telemetry 
:: Copy COMMERCIAL ID KEY in above path and replace it in the line below
set commercialIDValue=Unknown

:: By Default script logs to both console and log file.
:: logMode == 0 log to console only
:: logMode == 1 log to file and console
:: logMode == 2 log to file only
set logMode=2

:: By Default script disables IE data collection
:: To enable it set AllowIEData=IEDataOptIn and set IEOptInLevel
set AllowIEData=disabled

::IEOptInLevel=0 Internet Explorer data collection is disabled
::IEOptInLevel=1 Data collection is enabled for sites in the Local intranet + Trusted sites + Machine local zones
::IEOptInLevel=2 Data collection is enabled for sites in the Internet + Restricted sites zones
::IEOptInLevel=3 Data collection is enabled for all sites 
set IEOptInLevel=0

:: OptIn to send data related to "script run errors" to Microsoft Azure AppInsights Portal. This is disabled when AppInsightsOptIn=false
:: This data will help the Upgrade readiness team to understand the common errors encountered when running the configuration script and improve future versions of the script.
:: For more information, please see https://technet.microsoft.com/en-us/itpro/windows/deploy/upgrade-readiness-get-started#deploy-the-upgrade-readiness-deployment-script
set AppInsightsOptIn=true

:: The Compatibility Update KB runs Appraiser which is the data collector for upgrade readiness.
:: If Appraiser is already running, the script will wait and do this number of retries at interval of 60 secs.
:: If Appraiser is still running after all the retries are exhausted, the script will exit with an error code.
set NoOfAppraiserRetries=15

:: Switch to select if the client machines are behind a proxy
:: ClientProxy=Direct means there is no proxy, the connection to the end points is direct
:: ClientProxy=System means there is a system wide proxy. It does not require Authentication. The client machine should have the proxy configured through netsh
:: ClientProxy=User means the proxy is configured through IE and it might or migt not require user authentication. We will still need to go through authenticated route.
:: Please see https://go.microsoft.com/fwlink/?linkid=843397 for more information
set ClientProxy=Direct

set source="%~dp0"
set sourceWithoutQuotes=%source:"=%

for /f %%i in ('Powershell.exe $pshome') do set PowershellHome=%%i

:: Make sure we are running x64 PS on 64 bit OS. If not then start a new x64 process of powershell
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

if %OS%==64BIT (
if exist %WINDIR%\sysnative\reg.exe (
set PowershellHome=%PowershellHome:syswow64=sysnative%
) 
)

if exist %PowershellHome%\powershell.exe.config ( 
  Copy /Y %PowershellHome%\powershell.exe.config %source%\powershell.exe.config.bak
  Copy /Y %source%\powershell.exe.config %PowershellHome%\powershell.exe.config
) else (
  Copy /Y %source%\powershell.exe.config  %PowershellHome%\powershell.exe.config
)

set powershellCommand="&{&'%sourceWithoutQuotes%ConfigScript.ps1' %runMode% '%logPath%' %commercialIDValue% %logMode% %AllowIEData% %IEOptInLevel% %AppInsightsOptIn% %NoOfAppraiserRetries% %ClientProxy%; exit $LASTEXITCODE}"

%PowershellHome%\powershell.exe -ExecutionPolicy Bypass -Command %powershellCommand%
@echo %ERRORLEVEL%
set exitCode = %ERRORLEVEL%

:: restore the powershell.exe.config to what was before if there was one, or else remove it
if exist %source%\powershell.exe.config.bak (
   Copy %source%\powershell.exe.config.bak %PowershellHome%\powershell.exe.config
   Del /F /Q %source%\powershell.exe.config.bak
) else (
   Del /F /Q   %PowershellHome%\powershell.exe.config
)

set powershellCommand=""
set sourceWithoutQuotes=""
set source=""
set PowershellHome=""
exit /b %exitCode%