Param(
    [Parameter(Mandatory = $false)]
    [string] $SubscriptionId = "3f954a4a-8cbf-448d-b855-bcafd4db20f1",

    [Parameter(Mandatory = $false)]
    [string] $ResourceGroupName = "CTTestingRGNE13546",

    [Parameter(Mandatory = $false)]
    [string] $AutomationAccountName = "AA-CT-TestNE13546",

    [Parameter(Mandatory = $false)]
    [string] $WorkspaceName = "LAWS-CT-TestNE13546",

    [Parameter(Mandatory = $false)]
    [string] $WindowsFileSettingName = "custompssetting4",

    [Parameter(Mandatory = $false)]
    [ValidateSet("File", "Folder")]
    [string] $WindowsFilePathType = "File",

    [Parameter(Mandatory = $false)]
    [string] $WindowsFilePath = "D:\testest\*.*",

    [Parameter(Mandatory = $false)]
    [bool] $WindowsFileRecurse = $true,

    [Parameter(Mandatory = $false)]
    [bool] $WindowsFileUploadContent = $true,

    [Parameter(Mandatory = $false)]
    [string] $LinuxFileSettingName = "custompssetting4",

    [Parameter(Mandatory = $false)]
    [ValidateSet("File", "Folder")]
    [string] $LinuxFilePathType = "File",

    [Parameter(Mandatory = $false)]
    [string] $LinuxFilePath = "/home/azureuser/folderfolder/*",

    [Parameter(Mandatory = $false)]
    [bool]$LinuxFileRecurse = $true,

    [Parameter(Mandatory = $false)]
    [bool]$LinuxFileUploadContent = $true,

    [Parameter(Mandatory = $false)]
    [bool]$LinuxFileUseSudo = $true,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Follow", "Ignore", "Manage")]
    [string] $LinuxFileLinks = "Follow",

    [ValidateRange(10,1800)]
    [int] $WindowsServiceFrequencyInSec = 1800,

    [Parameter(Mandatory = $false)]
    [string] $WindowsRegistrySettingName = "custompssetting4",

    [Parameter(Mandatory = $false)]
    [string] $WindowsRegistryKey = "HKEY_LOCAL_MACHINE\Test\HelloWorld4",

    [Parameter(Mandatory = $false)]
    [bool]$WindowsRegistryRecurse = $false    
)

# Log-in to Azure Account

function Add-WindowsFileSetting{

    # PUT call to add tracking of Windows File in Automation Account ChangeTracking settings
    $apiUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingCustomPath_$WindowsFileSettingName" + "?api-version=2015-11-01-preview"

    $body = @{
    "id"="/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingCustomPath_$WindowsFileSettingName"
    "name"= "ChangeTrackingCustomPath$WindowsFileSettingName"
    "etag"= ""
    "kind"="ChangeTrackingCustomPath"
    "type"="workspaces"
    "location"= $ResourceGroupName
    "properties"= @{
            "checksum"="Md5"
            "enabled"=$true
            "groupTag"="Custom"
            "maxContentsReturnable"=if ($WindowsFileUploadContent -eq $true) {5000000} else {0}
            "maxOutputSize"=0
            "path"= $WindowsFilePath
            "pathType" = $WindowsFilePathType
            "recurse" = $WindowsFileRecurse
       }
    }

    return $apiUri, $body
}

function Add-LinuxFileSetting{

    # PUT call to add tracking for Linux File in Automation Account CahngeTracking settings
    $apiUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingLinuxPath_$LinuxFIleSettingName" + "?api-version=2015-11-01-preview"

    $body = @{
    "id"="/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingLinuxPath_$LinuxFileSettingName"
    "name"= "ChangeTrackingLinuxPath_$LinuxFileSettingName"
    "etag"= ""
    "kind"="ChangeTrackingLinuxPath"
    "type"="workspaces"
    "location"= $ResourceGroupName
    "properties"= @{
            "checksum"="Sha256"
            "enabled"=$true
            "groupTag"="Custom"
            "maxContentsReturnable"=if ($LinuxFileUploadContent -eq $true) {5000000} else {0}
            "maxOutputSize"=5000000
            "destinationPath"= $LinuxFilePath
            "pathType" = $LinuxFilePathType
            "recurse" = $LinuxFileRecurse
            "useSudo" = $LinuxFileUseSudo
            "links" = $LinuxFileLinks
       }
    }

    return $apiUri, $body

}

function Edit-WindowsServiceFrequency{

    # PUT call to change collection frequency for services in Automation Account ChangeTracking settings
    $apiUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingServices_CollectionFrequency?api-version=2015-11-01-preview"

    $body = @{
        "kind" = "ChangeTrackingServices"
        "id" = "/subscriptions$SubscriptionId/resourcegroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingServices_CollectionFrequency"
        "etag" = $null
        "name" = "ChangeTrackingServices_CollectionFrequency"
        "type" = "Microsoft.OperationalInsights/workspaces/datasources"
        "properties" = @{
            "ServiceName" = $null
            "ServiceStartupType" = $null
            "ServiceState" = $null
            "ServiceAccount" = $null
            "ListType" = "BlackList"
            "CollectionTimeInterval" = $WindowsServiceFrequencyInSec
            "LastUpdate" = $null
            "DataSourceType" = $null
            "DataSourceId" = $null
            "DataSourceETag" = $null
            }
    }

    return $apiUri, $body

}

function Enable-WindowsRegistrySetting{

    $apiUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingDefaultRegistry_$WindowsRegistrySettingName" + "?api-version=2015-11-01-preview"

    $body = @{
        "id" = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$WorkspaceName/datasources/ChangeTrackingDefaultRegistry_$WindowsRegistrySettingName"
        "name" = "ChangeTrackingDefaultRegistry_$WindowsRegistrySettingName"
        "etag" = ""
        "kind" = "ChangeTrackingDefaultRegistry"
        "type" = "workspaces"
        "location" = $ResourceGroupName
        "properties" =  @{
            "enabled" = $true
            "groupTag" = "Custom"
            "keyName" = $WindowsRegistryKey
            "valueName" = ""
            "recurse" = $WindowsRegistryRecurse
        }
    }
    return $apiUri, $body

}

function Get-AccessToken {
    $context = Get-AzContext
    $profile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($profile)
    $token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
    return $token.AccessToken
}

function CTRestCall($operationFunction){

    $apiUri, $body = Invoke-Command $operationFunction
    $requestBody = $body | ConvertTo-Json -Compress
    $requestHeaders = @{
        "Authorization" = "Bearer " + (Get-AccessToken)
    }
    Try{
        $response = Invoke-WebRequest -Method PUT -Uri $apiUri -Body $requestBody -ContentType "application/json" -Headers $requestHeaders -UseBasicParsing
        if($response.StatusCode -eq 200){
            Write-Output "The operation was successful." 
        }
        else{
            Write-Output "Response Code: " + $response.StatusCode 
        }
        Write-Output $response
        
    }
    Catch{
        Write-Output "The call failed with the following error: " 
        Write-Output $Error 
    }

}

# $context = Get-AzContext

# if (!$context -or ($context.Subscription.Id -ne $SubscriptionId)) 
# {
#     Connect-AzAccount -Subscription $SubscriptionId
# } 
# else 
# {
#     Set-AzContext -Subscription $SubscriptionId
# }

#Connect to Azure
try {  
    Write-Output  "Logging in to Azure..." -verbose
    $adAppCredName = "CTAuthentication"
    $adAppTenantIdName = "TenantID"

    $cred = Get-AutomationPSCredential -Name $adAppCredName
    $TenantId = Get-AutomationVariable -Name $adAppTenantIdName
    
    Connect-AzAccount -Credential $cred -Tenant  $TenantId -ServicePrincipal
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output "Changing Windows File Settings"
CTRestCall ${function:\Add-WindowsFileSetting}

Write-Output "Changing Linux File Settings"
CTRestCall ${function:\Add-LinuxFileSetting}

Write-Output "Changing Windows Service Frequency setting"
CTRestCall ${function:\Edit-WindowsServiceFrequency}

Write-Output "Changing Windows Registry Settings"
CTRestCall ${function:\Enable-WindowsRegistrySetting}