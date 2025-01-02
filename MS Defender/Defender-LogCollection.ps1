# Start

$OrigWindowPath = $pwd

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$WindowAdminContext = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$value = $WindowAdminContext.ToString()
$DefenderOutputPath = "C:\ProgramData\Microsoft\Windows Defender\Support\"
$copypath = "C:\Defender\"

if ($value.Contains("False")) {
    Write-Host "NOT running as elevated - please re-run the script as admin" -ForegroundColor Yellow
    pause
    exit
    } else {
    Write-Host "Running as admin - script continuing" -ForegroundColor Cyan
    
    Write-Host "Starting Defender trace - Output default: C:\ProgramData\Microsoft\Windows Defender\Support\" -ForegroundColor Cyan
    Start-Process "C:\Program Files\Windows Defender\mpcmdrun.exe" -ArgumentList GetFiles
    Write-Host "Completed Defender trace" -ForegroundColor Green
    

    #cd $env:userprofile\downloads
    
    if (Test-Path $copypath) {
        Write-Host "Folder exists..." -ForegroundColor Green
        
        Write-Host "Starting Perfromance trace - Output default: $copypath" -ForegroundColor Cyan
        cd $copypath
        New-MpPerformanceRecording -RecordTo recording.etl
        Write-Host "Completed Performance trace" -ForegroundColor Green
        

        Write-Host "Has Defender logging completed?? -- If not >> WAIT" -ForegroundColor Yellow
        Pause

        cd $DefenderOutputPath
        $defendercopylist = Get-ChildItem | sort LastWriteTime -Descending
        $topdefendercopylist = $defendercopylist[0..3]
        foreach ($file in $topdefendercopylist) {
            Write-Host "Copying $($file.name)..." -ForegroundColor Blue
            Copy-Item $file.name -Destination $copypath
        }
        Write-Host "Copying COMPLETE!" -ForegroundColor Green

    } else {
        New-Item -ItemType Directory $copypath

        Write-Host "Folder created..." -ForegroundColor DarkGreen
        
        Write-Host "Starting Perfromance trace - Output default: $copypath" -ForegroundColor Cyan
        cd $copypath
        New-MpPerformanceRecording -RecordTo recording.etl
        Write-Host "Completed Performance trace" -ForegroundColor Green
        
        Write-Host "Has Defender logging completed?? -- If not >> WAIT" -ForegroundColor Yellow
        Pause

        cd $DefenderOutputPath
        $defendercopylist = Get-ChildItem | sort LastWriteTime -Descending
        $topdefendercopylist = $defendercopylist[0..3]
        foreach ($file in $topdefendercopylist) {
            Write-Host "Copying $($file.name)..." -ForegroundColor Blue
            Copy-Item $file.name -Destination $copypath
        }
        Write-Host "Copying COMPLETE!" -ForegroundColor Green
    }





    }
    
cd $OrigWindowPath
Pause

#exit

# End
