param(
    #The name of the subscription to take all the operations within. 
    [Parameter(Mandatory = $true)] 
    [string]$SubscriptionName, 

    # The name of the storage account to enumerate.
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
 
    # The name of the storage container to enumerate.
    [Parameter(Mandatory = $true)]
    [string]$ContainerName,
	
	# The name of the storage container to enumerate.
    [Parameter(Mandatory = $true)]
    [string]$blobName
)

#Check if Windows Azure PowerShell Module is avaliable
If((Get-Module -ListAvailable Azure) -eq $null)
{
    Write-Warning "Windows Azure PowerShell module not found! Please install from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools";
}
Else
{
    # 由于.NET SDK版本不同，请确认下面这个路径是否存在，如果不存在，请在C盘按照文件夹路径依次查找，并修正下面这个路径
    add-type -Path 'C:\Program Files\Microsoft SDKs\Azure\.NET SDK\v2.5\bin\Microsoft.WindowsAzure.StorageClient.dll';
	 
    $blobUri = "https://" + $StorageAccountName + ".blob.core.chinacloudapi.cn/" + $ContainerName + "/"
    $blobPath = "Restored"  + $blobname

    #get the storage account key
    $key = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary

    #generate credentials based on the key
    $creds = New-Object Microsoft.WindowsAzure.StorageCredentialsAccountAndKey($StorageAccountName,$key)
      
    #create an instance of the CloudBlobClient class
    $blobClient = New-Object Microsoft.WindowsAzure.StorageClient.CloudBlobClient($blobUri, $creds)

    #and grab a reference to our target blob
    $blob = $blobClient.GetBlobReference($blobPath)

    $BlobOptions = New-Object Microsoft.WindowsAzure.StorageClient.BlobRequestOptions
    $BlobOptions.BlobListingDetails = "Snapshots"
    $BlobOptions.UseFlatBlobListing = $true
    $BlobSnapshots = $Blob.Container.ListBlobs($BlobOptions);
    
    #Get all snapshots of specified blob
    $Snapshots = $BlobSnapshots | Where{$_.Name -eq $blobName -and $_.SnapshotTime -ne $null}
    
    #Declare the initial variable 
    $Index = 0
    $SnapshotLists = @()

    #Create a snapshot list for user reference
    Foreach($Snapshot in $Snapshots)
    {
        $Index++
        $SnapshotLists += [PSCustomObject]@{ID = $Index;
                                            BlobName = $blobName
                                            SnapshotTime = $Snapshot.SnapshotTime
                                            SnapshotUri = $Snapshot.Uri}
    }
    
    Write-Host "The '$BlobName' blob has the following snapshot:" 
    $SnapshotLists | Format-Table -AutoSize
    $inputID = Read-Host "Please input the corresponding number of ID that you want to restore"
    
    #Matching the corresponding number of ID
    $SnapshotTime = $SnapshotLists | Where{$_.ID -eq $inputID} | Select -ExpandProperty SnapshotTime

    #Get the corresponding snapshot of blob
    $RestorePoint = $Snapshots | Where{$_.SnapshotTime -eq $SnapshotTime}
    
    $CorrespondingSnapshot = $SnapshotLists | Where{$_.ID -eq $inputID} | Select -ExpandProperty SnapshotUri
    
    If($PSCmdlet.ShouldContinue("Restore storage '$BlobName' blob from '($SnapshotTime)$CorrespondingSnapshot'","Confirm Restore Opeartion"))
    {
        #Starting recover blob
        Write-Verbose "Recovering storage blob from snapshot."
        $blob.CopyFromBlob($RestorePoint)
        Write-Host "Successfully restored '$BlobName' blob."
    }
}