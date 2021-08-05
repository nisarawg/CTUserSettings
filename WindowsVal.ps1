Param( 
    [string] $outdir = "D:\testfolder",
    [int] $fileTimeintervalinMin = 45,
    [int] $servicesTimeintervalinMin = 10,
    [int] $numberLoops = 5,
    [array] $servicesTest = @("bthserv","lfsvc")
)


$FileChanges = { 
    Param( 
        [string] $outdir = "D:\testfolder",
        [int] $fileTimeintervalinMin = 45
    )

    function Add-File{
        Param(
         [String]$FileName 
       ,[String]$FileContent="created at" 
         )
         $time = Get-Date -DisplayHint Time
         $FileContent += $time
         Write-Host "Adding file $FileName with content:  $FileContent"
       Set-Content -Path $FileName -Value $FileContent
   }
   
   function Modify-File{
       Param(
       [String]$FileName,
       [String]$FileContent="modified at"
       )
       $time = Get-Date -DisplayHint Time
       $FileContent += $time
       Write-Host "Modifying file $FileName with content:  $FileContent"
       Add-Content -Path $FileName -Value $FileContent
   }
   
   function Rem-File{
        Param(
         [String]$FileName 
         )
         Write-Host "Removing file $FileName "
       Remove-Item -Path $FileName        
   }

    New-Item -ItemType Directory -Force -Path $outdir
    cd  $outdir
    $filesAdd= "f1.txt" ,"f2.txt","f3.txt"

    # Adding the files f1,f2,f3 in Start tracking state in first cycle.
    Foreach($file in $filesAdd){
        Add-File $file
    }
    Start-Sleep -Seconds ($fileTimeintervalinMin*60) 

    # Adding the files f4, modifying f3 and removing f1 in second cycle.
    Add-File "f4.txt"
    Modify-File "f3.txt" 
    Modify-file "f2.txt"
    Rem-File "f1.txt"
    Start-Sleep -Seconds ($fileTimeintervalinMin*60) 

    # removing f4,f3,f2 in third cycle.
    Modify-File "f3.txt" 
    Modify-file "f2.txt"
    Modify-File "f4.txt"
    Start-Sleep -Seconds ($fileTimeintervalinMin*60)

    Modify-File "f3.txt" 
    Modify-file "f2.txt"
    Modify-File "f4.txt"
}

$ServiceChanges = { 
    Param( 
        [int] $servicesTimeintervalinMin = 20,
        [int] $numberLoops = 5,
        [array] $servicesTest = @("bthserv","lfsvc")
    )

    
    function Change-ServiceState{
        Param(
        [String] $serviceName
        )
        Get-Service -Name $serviceName | %{if ($_.Status -eq "Running") {
        Stop-Service -Name $serviceName -Force -PassThru} else {
        Start-Service -Name $serviceName -PassThru}}
        #Set-Service -Name $serviceName -Status $serviceStatus -PassThru
    }

    for ($i=0; $i -le $numberLoops; $i++){
        Write-Host "Loop $i :: "
        foreach($service in $servicesTest){ 
            Change-ServiceState $service
        }
               
        Start-Sleep -Seconds ($servicesTimeintervalinMin * 60)
    }
}

$SoftwareChanges = { 
    $LocalTempDir = $env:TEMP 
    $ChromeInstaller = "ChromeInstaller.exe" 
    (new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller")
    & "$LocalTempDir\$ChromeInstaller" /silent /install
    $Process2Monitor =  "ChromeInstaller" 
    Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name 
    If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host
    Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)
}

Start-Job -ScriptBlock $FileChanges -ArgumentList @($outdir, $fileTimeintervalinMin)
Start-Job -ScriptBlock $ServiceChanges -ArgumentList @($servicesTimeintervalinMin, $numberLoops, $servicesTest)
Start-Job -ScriptBlock $SoftwareChanges

