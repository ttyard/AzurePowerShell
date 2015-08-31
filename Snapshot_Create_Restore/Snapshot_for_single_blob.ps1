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

Set-AzureSubscription -SubscriptionName $SubscriptionName -CurrentStorageAccount $StorageAccountName;
$storageAccessKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary;
$storageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccessKey -Environment AzureChinaCloud 
$blobClient = $storageContext.Context.StorageAccount.CreateCloudBlobClient()

Write-Verbose "Getting the container object named $containerName."
$blobContainer = $blobClient.GetContainerReference($ContainerName)

Write-Verbose "Getting the blob object named $blobName."
$blob = $blobContainer.GetBlockBlobReference($blobName)

Try
{
	$Blob.CreateSnapshot() | Out-Null
	Write-Host "Successfully create a snapshot of blob '$blobName'."
}
Catch
{
	 Write-Host "Failed to create a snapshot of blob '$blobName'." -ForegroundColor Red
	 throw;
};