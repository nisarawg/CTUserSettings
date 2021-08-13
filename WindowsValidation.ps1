Param( 

    [Parameter(Mandatory = $false)]
    [string] 
    $outDirForFiles = "D:\testfolder",

    [Parameter(Mandatory = $false)]
    [int]
    $fileIntervalinMin = 45,

    [Parameter(Mandatory = $false)]
    [int] 
    $servicesIntervalinMin = 10,

    [Parameter(Mandatory = $false)]
    [int] 
    $numberLoopsForServices = 5,

    [Parameter(Mandatory = $false)]
    [array] 
    $servicesToTest = @("bthserv")
)

$CheckIfMPExists = {
    Param( 

    [Parameter(Mandatory = $false)]
    [string] 
    $outDirForFiles = "D:\testfolder",

    [Parameter(Mandatory = $false)]
    [int]
    $fileIntervalinMin = 45,

    [Parameter(Mandatory = $false)]
    [int] 
    $servicesIntervalinMin = 10,

    [Parameter(Mandatory = $false)]
    [int] 
    $numberLoopsForServices = 5,

    [Parameter(Mandatory = $false)]
    [array] 
    $servicesToTest = @("bthserv")
)

$FileChanges = { 

    Param( 
        [Parameter(Mandatory = $false)]
        [string] 
        $outdir = "D:\testfolder",

        [Parameter(Mandatory = $false)]
        [int] 
        $fileIntervalinMin = 45
    )

    function Add-File{

        Param(
            [Parameter(Mandatory = $true)]
            [String]
            $FileName,

            [Parameter(Mandatory = $false)]
            [String]
            $FileContent = "File created at "    
        )

        $FileContent += (Get-Date -DisplayHint Time)
        Write-Host "Adding file $FileName with content:  $FileContent"
        Set-Content -Path $FileName -Value $FileContent
   }
   
   function Modify-File{
       
    Param(
        [Parameter(Mandatory = $true)]
        [String]
        $FileName,

        [Parameter(Mandatory = $false)]
        [String]
        $FileContent = "File modified at "
       )

       $FileContent += (Get-Date -DisplayHint Time)
       Write-Host "Modifying file $FileName with content:  $FileContent"
       Add-Content -Path $FileName -Value $FileContent

    }
   
   function Rem-File{

        Param(
            [Parameter(Mandatory = $true)]
            [String]
            $FileName 
        )

        Write-Host "Removing file $FileName "
        Remove-Item -Path $FileName        
   }

    New-Item -ItemType Directory -Force -Path $outdir
    Set-Location -Path  $outdir

    $filesToAdd= @("file1.txt" ,"file2.txt","file3.txt")

    # Adding the first 3 files in Start tracking state in first cycle.
    Foreach($file in $filesToAdd){
        Add-File $file
    }
    Start-Sleep -Seconds ($fileIntervalinMin*60) 

    # Adding the files f4, modifying f3 and removing f1 in second cycle.
    Foreach($file in $filesToAdd){
        Modify-File $file
    }
    Add-File "file4.txt"
    $filesToAdd += "file4.txt"
    Start-Sleep -Seconds ($fileIntervalinMin*60) 

    # modifying all files, removing file1.
    Foreach($file in $filesToAdd){
        Modify-File $file
    }
    $filesToAdd = $filesToAdd -ne "file1.txt"
    Rem-File "file1.txt"
    Start-Sleep -Seconds ($fileIintervalinMin*60)

    #removing all files
    Foreach($file in $filesToAdd){
        Rem-File $file
    }
}

$ServiceChanges = { 
    Param( 
        [Parameter(Mandatory = $false)]
        [int] 
        $servicesIntervalinMin = 20,

        [Parameter(Mandatory = $false)]
        [int] 
        $numberLoops = 5,

        [Parameter(Mandatory = $false)]
        [array] 
        $servicesToTest = @("bthserv","lfsvc")
    )

    
    function Change-ServiceState{
        Param(
            [Parameter(Mandatory = $true)]
            [String] 
            $serviceName
        )
        Get-Service -Name $serviceName | %{if ($_.Status -eq "Running") {
            Stop-Service -Name $serviceName -Force -PassThru} else {
                Start-Service -Name $serviceName -PassThru}}
        #Set-Service -Name $serviceName -Status $serviceStatus -PassThru
    }

    for ($i=0; $i -le $numberLoops; $i++){
        Write-Host "Loop $i :: "
        foreach($service in $servicesToTest){ 
            Change-ServiceState $service
        }
               
        Start-Sleep -Seconds ($servicesIntervalinMin * 60)
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

function FileExists{
    Param(
        [Parameter(Mandatory = $true)]
        [string] $fileName
    )

    return (Test-Path $fileName -PathType Leaf)
}

    Enable-PSRemoting –Force
    
    $MPFolder = "$env:HOMEDRIVE\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Management Packs"
    $ChangeTrackingDirectAgentMP = "$MPFolder\Microsoft.IntelligencePacks.ChangeTrackingDirectAgent*"
    $InventoryChangeTrackingMP = "$MPFolder\Microsoft.IntelligencePacks.InventoryChangeTracking*"

    while(!(FileExists($ChangeTrackingDirectAgentMP)) -and !(FileExists($InventoryChangeTrackingMP))){
        Write-Host "ChangeTracking and Inventory MPs have not been downloaded yet. Going back to sleep..."
        Start-Sleep 900
    }
    Write-Host "ChangeTracking and Inventory MPs were downloaded! :)"
    Start-Sleep 180
    
    # Start-Job -ScriptBlock $FileChanges -ArgumentList @($outDirForFiles, $fileIntervalinMin)
    # Start-Job -ScriptBlock $ServiceChanges -ArgumentList @($servicesIntervalinMin, $numberLoopsForServices, $servicesToTest)
    # Start-Job -ScriptBlock $SoftwareChanges
    Invoke-Command -ScriptBlock $FileChanges -ArgumentList @($outDirForFiles, $fileIntervalinMin)
    Invoke-Command -ScriptBlock $ServiceChanges -ArgumentList @($servicesIntervalinMin, $numberLoopsForServices, $servicesToTest)
    Invoke-Command -ScriptBlock $SoftwareChanges
    

    # Get-Job | Wait-Job
}

Invoke-Command -ScriptBlock $CheckIfMPExists -ArgumentList @($outDirForFiles, $fileIntervalinMin, $servicesIntervalinMin, $numberLoopsForServices, $servicesToTest)

